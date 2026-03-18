# Detailed Code Guide — Restaurant iOS App

## Table of Contents

1. [App Entry Point](#1-app-entry-point)
2. [Dependency Injection — DIContainer](#2-dependency-injection--dicontainer)
3. [Domain Layer — Entities](#3-domain-layer--entities)
4. [Domain Layer — Repository Protocols](#4-domain-layer--repository-protocols)
5. [Domain Layer — Use Cases](#5-domain-layer--use-cases)
6. [Data Layer — Repositories](#6-data-layer--repositories)
7. [Data Layer — MockDataSource](#7-data-layer--mockdatasource)
8. [Presentation Layer — ViewModels](#8-presentation-layer--viewmodels)
9. [Presentation Layer — Views](#9-presentation-layer--views)
10. [Presentation Layer — Components](#10-presentation-layer--components)
11. [Core — Constants & Extensions](#11-core--constants--extensions)
12. [End-to-End App Flow](#12-end-to-end-app-flow)
13. [Swift Concurrency Patterns Used](#13-swift-concurrency-patterns-used)
14. [Design Decisions & Comparisons](#14-design-decisions--comparisons)

---

## 1. App Entry Point

### `restaurantApp.swift`

```swift
@main
struct restaurantApp: App {
    @StateObject private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(container)
        }
    }
}
```

### Why `@StateObject` here?

| Property Wrapper | Ownership | Use When |
|-----------------|-----------|----------|
| `@StateObject` | **Owns** the object, creates it once | App/root view that creates the object |
| `@ObservedObject` | Does NOT own, just observes | Child views that receive the object |
| `@EnvironmentObject` | Reads from environment | Any descendant view that needs it |

`@StateObject` is used here because `restaurantApp` is the **owner** of `DIContainer`. It creates it once for the entire app lifetime. If we used `@ObservedObject`, the container could be recreated on re-renders, losing all state.

### Why `.environmentObject(container)` not `.environment(container)`?

| Modifier | Protocol Required | Access in Child |
|----------|-----------------|----------------|
| `.environmentObject()` | `ObservableObject` | `@EnvironmentObject` |
| `.environment()` | `Observable` macro | `@Environment(Type.self)` |

We use `ObservableObject` (not `@Observable`) because `DIContainer` needs `lazy` stored properties — `@Observable` macro converts stored properties to computed ones, which breaks `lazy`. So we use the classic `ObservableObject` + `.environmentObject()` pair.

---

## 2. Dependency Injection — DIContainer

### `DIContainer.swift`

```swift
final class DIContainer: ObservableObject {
    private lazy var menuRepository: MenuRepositoryProtocol = MenuRepository(dataSource: mockDataSource)
    private lazy var getCategoriesUseCase: GetCategoriesUseCaseProtocol = GetCategoriesUseCase(repository: menuRepository)
    lazy var sharedCartViewModel: CartViewModel = makeCartViewModel()

    func makeMenuViewModel() -> MenuViewModel { ... }
}
```

### Why `lazy` for repositories and use cases?

`lazy` means the object is only created when first accessed. Benefits:
- **Performance**: If the user never visits the Reservation tab, `reservationRepository` is never created
- **Dependency order**: `menuRepository` can safely reference `mockDataSource` because `lazy` evaluates at access time, not at init time
- **Memory**: Objects that aren't needed don't consume memory

### Why `sharedCartViewModel` is `lazy` but public?

The cart must be **shared** between `MenuView` (add to cart) and `CartView` (view cart). If each tab created its own `CartViewModel`, they would have different cart states. `sharedCartViewModel` ensures one single cart instance is passed to both tabs.

```
MenuView ──────────────────────────────────────────┐
                                                    ▼
                                          sharedCartViewModel (one instance)
                                                    ▲
CartView ──────────────────────────────────────────┘
```

### Why factory methods (`makeMenuViewModel()`) instead of lazy ViewModels?

ViewModels that are **not shared** (Menu, Reservation, Profile, Restaurant) are created fresh via factory methods. This means:
- Each tab gets a clean ViewModel with no stale state
- The ViewModel is only created when the tab is first visited
- If the user navigates away and back, the View re-creates the ViewModel via `.task`

### Why `final class` not `struct`?

`DIContainer` must be a `class` because:
1. `ObservableObject` requires a class
2. `lazy` properties require a class (structs are value types, `lazy` needs mutability via `mutating` which doesn't work with protocols)
3. It is shared by reference across the entire app

---

## 3. Domain Layer — Entities

### Why `struct` for all Entities?

```swift
struct MenuItem: Identifiable, Equatable, Hashable { ... }
struct Cart: Equatable { ... }
struct Order: Identifiable, Equatable { ... }
```

| Type | Copying | Thread Safety | Use When |
|------|---------|---------------|----------|
| `struct` | Value copy | Inherently safe | Data models, no shared mutable state |
| `class` | Reference | Needs synchronization | Identity matters, shared mutation |

Entities are **pure data** — they represent what the business domain looks like. Using structs means:
- Passing a `MenuItem` to a function never mutates the original
- Two threads can read the same `MenuItem` safely
- SwiftUI's diffing works correctly (Equatable comparison)

### Why `Identifiable` on entities?

`Identifiable` provides a stable `id` property. SwiftUI's `ForEach` requires it to efficiently diff lists — it knows which items were added, removed, or moved without re-rendering everything.

### Why `Hashable` on `MenuItem` and `Category`?

`Hashable` is needed when using these types in `Set` or as `Dictionary` keys. It also enables SwiftUI's `ForEach` with `.id(\.self)` and efficient lookups.

### `Cart` — Why a `struct` with `mutating` methods?

```swift
struct Cart: Equatable {
    mutating func addItem(_ menuItem: MenuItem, ...) { ... }
    mutating func clear() { ... }
}
```

`Cart` is a value type. When `CartRepository` (an actor) modifies it:
```swift
var updated = cart       // creates a copy
updated.addItem(item)    // mutates the copy
cart = updated           // replaces the stored cart
```
This pattern is required because Swift actors protect their state — you cannot pass `inout` to an async context. The copy-mutate-replace pattern is the correct Swift approach.

### Why nested enums inside entities?

```swift
struct Order {
    enum OrderStatus { case pending, confirmed, preparing, ready, delivered, cancelled }
    enum OrderType { case pickup, delivery, dineIn }
}
```

Nesting enums inside their parent entity:
- Groups related types logically (`Order.OrderStatus` vs standalone `OrderStatus`)
- Prevents namespace pollution
- Makes it clear the enum only makes sense in the context of `Order`

---

## 4. Domain Layer — Repository Protocols

### `MenuRepositoryProtocol.swift`

```swift
protocol MenuRepositoryProtocol: Sendable {
    func getCategories() async throws -> [Category]
    func getMenuItems(for categoryId: String?) async throws -> [MenuItem]
    func getMenuItem(id: String) async throws -> MenuItem
    func searchMenuItems(query: String) async throws -> [MenuItem]
}
```

### Why protocols instead of concrete types?

The Domain layer defines **what** data operations exist, not **how** they are implemented. This is the Dependency Inversion Principle:

```
ViewModel → UseCase → MenuRepositoryProtocol ← MenuRepository (mock)
                                             ← RealAPIMenuRepository (future)
```

Benefits:
- Swap `MockDataSource` for a real API without touching any ViewModel or UseCase
- Unit test UseCases with a `MockMenuRepository` that returns controlled data
- The Domain layer has zero knowledge of networking, databases, or mock data

### Why `Sendable`?

`Sendable` marks the protocol as safe to use across concurrency boundaries (actors, async tasks). Since all repository methods are `async`, Swift's strict concurrency checking requires that types crossing actor boundaries conform to `Sendable`.

### Why `async throws`?

- `async`: Data fetching is inherently asynchronous (network, disk). Using `async` instead of callbacks or completion handlers makes the code linear and readable.
- `throws`: Operations can fail (network error, item not found, invalid data). Using `throws` forces callers to handle errors explicitly.

---

## 5. Domain Layer — Use Cases

### Pattern: One Use Case = One Operation

```swift
final class GetMenuItemsUseCase: GetMenuItemsUseCaseProtocol, Sendable {
    private let repository: MenuRepositoryProtocol

    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute(categoryId: String? = nil) async throws -> [MenuItem] {
        try await repository.getMenuItems(for: categoryId)
    }
}
```

### Why one class per operation instead of one class per feature?

| Approach | Example | Problem |
|----------|---------|---------|
| One class per feature | `MenuService` with 10 methods | Grows unbounded, hard to test each method in isolation |
| One class per operation | `GetMenuItemsUseCase` | Single responsibility, easy to test, easy to find |

Each use case has exactly **one public method: `execute()`**. This makes the purpose immediately obvious from the class name.

### Why a protocol for each use case?

```swift
protocol GetMenuItemsUseCaseProtocol: Sendable {
    func execute(categoryId: String?) async throws -> [MenuItem]
}
```

The ViewModel depends on `GetMenuItemsUseCaseProtocol`, not `GetMenuItemsUseCase`. This means:
- In tests, inject a `MockGetMenuItemsUseCase` that returns controlled data
- The ViewModel never knows or cares about the implementation

### Business logic in Use Cases — `PlaceOrderUseCase`

```swift
func execute(cart: Cart, orderType: Order.OrderType, ...) async throws -> Order {
    guard !cart.isEmpty else { throw OrderError.emptyCart }  // business rule
    let order = try await orderRepository.placeOrder(...)
    _ = try await cartRepository.clearCart()                 // side effect
    return order
}
```

`PlaceOrderUseCase` coordinates **two repositories**: it places the order AND clears the cart. This business logic lives in the Use Case, not the ViewModel or Repository. The ViewModel just calls `execute()` and doesn't know about the cart-clearing side effect.

### Input validation in Use Cases — `MakeReservationUseCase`

```swift
guard partySize > 0 else { throw ReservationError.invalidPartySize }
guard date >= Calendar.current.startOfDay(for: Date()) else { throw ReservationError.invalidDate }
let trimmedName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
guard !trimmedName.isEmpty else { throw ReservationError.missingContactInfo }
```

Validation belongs in the Use Case because it is **business logic**, not UI logic. The same validation applies whether the input comes from a SwiftUI form, a REST API, or a unit test.

---

## 6. Data Layer — Repositories

### `actor` vs `class` for repositories

| Repository | Type | Why |
|-----------|------|-----|
| `CartRepository` | `actor` | Mutable shared state (cart items) — actor prevents data races |
| `OrderRepository` | `actor` | Mutable shared state (order list) |
| `ReservationRepository` | `actor` | Mutable shared state (reservation list) |
| `MenuRepository` | `final class` | Read-only data from MockDataSource — no mutation, no race conditions |
| `RestaurantRepository` | `final class` | Read-only data — no mutation needed |

### Why `actor` for CartRepository?

```swift
actor CartRepository: CartRepositoryProtocol {
    private var cart: Cart = Cart()
    ...
}
```

An `actor` serializes access to its mutable state. If two async tasks call `addToCart` simultaneously, the actor queues them — one runs, then the other. Without an actor, you'd get a data race (two tasks reading/writing `cart` at the same time = undefined behavior).

### Why `@unchecked Sendable` on MenuRepository?

```swift
final class MenuRepository: MenuRepositoryProtocol, @unchecked Sendable {
```

`MenuRepository` holds a reference to `MockDataSource` (a class). Swift can't automatically prove this is thread-safe. `@unchecked Sendable` tells the compiler "trust me, I've verified this is safe" — and it is, because `MockDataSource` is read-only (all `let` properties).

### Simulated network delay

```swift
private func simulateNetworkDelay() async throws {
    try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...500_000_000))
}
```

This simulates 200–500ms network latency. It serves two purposes:
1. Makes the loading states visible during development (skeleton cards, spinners)
2. Ensures the async/await flow is exercised correctly before connecting a real API

---

## 7. Data Layer — MockDataSource

### `MockDataSource.swift`

```swift
final class MockDataSource: Sendable {
    static let shared = MockDataSource()
    private init() {}

    let categories: [Category] = [...]
    let menuItems: [MenuItem] = [...]
    let restaurant = Restaurant(...)

    func generateTimeSlots(for date: Date) -> [TimeSlot] { ... }
}
```

### Why Singleton (`static let shared`)?

`MockDataSource` is stateless (all `let` properties). A singleton avoids creating multiple copies of the same 34-item menu array. All repositories share the same data source instance, so they all see the same menu.

### Why `private init()`?

Prevents anyone from creating a second instance of `MockDataSource`. The only way to access it is through `.shared`.

### Why `final`?

`final` prevents subclassing. Since `MockDataSource` is a singleton, subclassing would break the singleton pattern. `final` also gives the compiler permission to optimize method calls (no vtable lookup needed).

### Why `Sendable`?

`MockDataSource` is used by repositories that are actors and classes across async contexts. `Sendable` confirms it is safe to pass across concurrency boundaries — which it is, because all its properties are `let` (immutable).

---

## 8. Presentation Layer — ViewModels

### Pattern: `ObservableObject` + `@Published`

```swift
final class MenuViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading = false
    @Published var searchQuery: String = ""
}
```

### Why `ObservableObject` not `@Observable`?

| Feature | `ObservableObject` + `@Published` | `@Observable` macro |
|---------|----------------------------------|---------------------|
| `lazy` properties | ✅ Supported | ❌ Not supported (converts to computed) |
| `Combine` integration | ✅ Native | ⚠️ Requires bridging |
| `@StateObject` / `@EnvironmentObject` | ✅ Works | ❌ Use `@State` / `@Environment` instead |
| Granular tracking | ❌ Whole object | ✅ Per-property |
| iOS requirement | iOS 13+ | iOS 17+ |

We chose `ObservableObject` because `DIContainer` needs `lazy` properties, and mixing `@Observable` with `lazy` causes compiler errors. Consistency across all ViewModels makes the codebase easier to understand.

### Why `private(set)` on most `@Published` properties?

```swift
@Published private(set) var categories: [Category] = []   // read-only outside ViewModel
@Published var searchQuery: String = ""                    // read-write (bound to TextField)
```

`private(set)` means: "anyone can read this, but only this ViewModel can write it." This enforces unidirectional data flow — the View reads state but only triggers actions, it never directly mutates ViewModel state.

### Why `@MainActor` on action methods?

```swift
@MainActor
func loadInitialData() async {
    isLoading = true    // UI update — must be on main thread
    ...
    isLoading = false   // UI update — must be on main thread
}
```

`@Published` properties trigger UI updates. SwiftUI requires UI updates on the main thread. `@MainActor` guarantees the method runs on the main thread, preventing "Publishing changes from background threads is not allowed" warnings.

### Why inject use cases via `init` not create them inside?

```swift
// ✅ Correct — injected
init(getCategoriesUseCase: GetCategoriesUseCaseProtocol, ...) {
    self.getCategoriesUseCase = getCategoriesUseCase
}

// ❌ Wrong — created inside
init() {
    self.getCategoriesUseCase = GetCategoriesUseCase(repository: MenuRepository(...))
}
```

Injecting via `init` means:
- In tests, pass a `MockGetCategoriesUseCase` that returns controlled data
- The ViewModel has no knowledge of concrete implementations
- Dependencies are explicit and visible

---

## 9. Presentation Layer — Views

### `MainTabView.swift`

```swift
struct MainTabView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedTab: Tab = .menu

    var body: some View {
        TabView(selection: $selectedTab) {
            MenuView(cartViewModel: container.sharedCartViewModel)
                .tabItem { Label("Menu", systemImage: "menucard") }
                .tag(Tab.menu)

            CartView(viewModel: container.sharedCartViewModel)
                .tabItem { Label("Cart", systemImage: "cart") }
                .badge(container.sharedCartViewModel.itemCount)
            ...
        }
        .tint(AppColors.primary)
    }
}
```

### Why `@EnvironmentObject` not `@StateObject` in MainTabView?

`MainTabView` does **not own** `DIContainer` — `restaurantApp` owns it. `MainTabView` just reads from the environment. `@EnvironmentObject` is the correct choice for any view that receives (not creates) an `ObservableObject`.

### Why `container.sharedCartViewModel` passed explicitly to `MenuView` and `CartView`?

The cart must be the **same instance** in both tabs. If each tab created its own `CartViewModel`, adding an item in `MenuView` would not appear in `CartView`. Passing `sharedCartViewModel` explicitly ensures both views share one cart.

### Why `.badge(container.sharedCartViewModel.itemCount)` on the Cart tab?

`.badge()` shows a red number on the tab icon. It reads `itemCount` from the shared `CartViewModel` — when items are added from `MenuView`, the badge updates automatically because both views observe the same `CartViewModel`.

### Why `.tint(AppColors.primary)` on `TabView`?

`.tint` sets the accent color for the entire `TabView` — selected tab icons, tab bar indicators. Setting it once at the `TabView` level applies to all tabs without repeating it per tab.

---

### `MenuView.swift`

```swift
struct MenuView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewModel: MenuViewModel?
    @State private var cartViewModel: CartViewModel

    var body: some View {
        NavigationStack { ... }
        .task {
            if viewModel == nil {
                viewModel = container.makeMenuViewModel()
            }
            await viewModel?.loadInitialData()
        }
    }
}
```

### Why `@State private var viewModel: MenuViewModel?` (optional)?

The ViewModel is created lazily — only when the view first appears. `nil` means "not yet created." This pattern avoids creating the ViewModel before the view is in the hierarchy (which would waste resources if the tab is never visited).

### Why `.task { }` not `.onAppear { }`?

| Modifier | Async support | Cancellation | Lifecycle |
|----------|--------------|-------------|-----------|
| `.task { }` | ✅ Native `async/await` | ✅ Auto-cancelled on view disappear | Tied to view lifetime |
| `.onAppear { }` | ❌ Must use `Task { }` wrapper | ❌ Manual cancellation | Fires on every appear |

`.task` is the modern SwiftUI way to run async work. It automatically cancels the task when the view disappears, preventing memory leaks and unnecessary work.

### Why `NavigationStack` not `NavigationView`?

`NavigationView` is deprecated in iOS 16+. `NavigationStack` is the modern replacement with:
- Better performance
- Programmatic navigation via `NavigationPath`
- Correct behavior on iPad and Mac Catalyst

### Why `LazyVStack` not `VStack` in the menu list?

```swift
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(viewModel.displayedItems) { item in
            MenuItemCard(item: item) { ... }
        }
    }
}
```

`LazyVStack` only renders cells that are visible on screen. With 34 menu items, `VStack` would render all 34 at once. `LazyVStack` renders maybe 6–8 visible items, dramatically improving scroll performance.

### Why `@ViewBuilder` on helper methods?

```swift
@ViewBuilder
private func emptyContent(viewModel: MenuViewModel) -> some View {
    if viewModel.showingSearch {
        EmptyStateView(...)
    } else {
        EmptyStateView(...)
    }
}
```

`@ViewBuilder` allows returning different view types from a function using `if/else` without wrapping in `AnyView`. Without it, the function would need to return `AnyView`, which erases type information and hurts performance.

---

### `MenuItemDetailView.swift`

```swift
.safeAreaInset(edge: .bottom) {
    addToCartButton
}
```

### Why `safeAreaInset` not padding at the bottom of ScrollView?

| Approach | Problem |
|----------|---------|
| `padding(.bottom, 100)` on ScrollView | Last item hidden behind button, user must scroll extra |
| `VStack { ScrollView; Button }` | Button jumps when keyboard appears |
| `.safeAreaInset(edge: .bottom)` | ✅ ScrollView content avoids the button area automatically |

`.safeAreaInset` tells the scroll view "there is a floating element at the bottom — adjust your safe area inset so content is never hidden behind it." The scroll view automatically scrolls its last item above the button. This is the correct iOS pattern for floating action buttons.

### Why `axis: .vertical` on TextField for special instructions?

```swift
TextField("e.g., No onions...", text: $specialInstructions, axis: .vertical)
    .lineLimit(3...5)
```

`axis: .vertical` makes the `TextField` grow vertically as the user types, up to 5 lines. Without it, the text would overflow horizontally on a single line. `lineLimit(3...5)` sets the minimum height (3 lines) and maximum height (5 lines) before scrolling.

---

### `CartView.swift`

```swift
.alert("Error", isPresented: .constant(viewModel.error != nil)) {
    Button("OK") { viewModel.clearError() }
} message: {
    Text(viewModel.error ?? "")
}
```

### Why `.constant(viewModel.error != nil)` for the alert binding?

The alert's `isPresented` binding needs a `Binding<Bool>`. We derive it from `viewModel.error` — if there's an error, show the alert. `.constant()` creates a read-only binding. When the user taps OK, `clearError()` sets `error = nil`, which causes `viewModel.error != nil` to become `false`, dismissing the alert.

---

### `CheckoutView.swift`

```swift
.overlay {
    LoadingOverlay(isLoading: viewModel.isPlacingOrder, message: "Placing order...")
}
```

### Why `.overlay` for loading not replacing the whole view?

When placing an order, we want to:
1. Keep the checkout form visible (so the user sees what they ordered)
2. Show a loading indicator on top
3. Prevent interaction while loading

`.overlay` layers the `LoadingOverlay` on top without replacing the view. The `LoadingOverlay` uses `.ignoresSafeArea()` to cover the entire screen including the navigation bar.

### Why `safeAreaInset` for the "Place Order" button?

```swift
.safeAreaInset(edge: .bottom) {
    placeOrderButton
}
```

Same reason as `MenuItemDetailView` — the scrollable checkout form should not be hidden behind the sticky "Place Order" button. The scroll view automatically adjusts.

---

### `ReservationFormView.swift`

```swift
DatePicker(
    "Date",
    selection: $viewModel.selectedDate,
    in: viewModel.minDate...viewModel.maxDate,
    displayedComponents: .date
)
.datePickerStyle(.graphical)
.onChange(of: viewModel.selectedDate) { _, _ in
    Task { await viewModel.loadAvailableSlots() }
}
```

### Why `.datePickerStyle(.graphical)` not `.compact` or `.wheel`?

| Style | Appearance | Best For |
|-------|-----------|----------|
| `.graphical` | Full calendar grid | Reservation booking — user sees the whole month |
| `.compact` | Single tap-to-expand | Forms with limited space |
| `.wheel` | Spinning drum | Time selection |

For reservations, users want to see the full calendar to pick a date relative to today. `.graphical` is the most intuitive for this use case.

### Why `in: viewModel.minDate...viewModel.maxDate`?

This restricts the `DatePicker` to a valid range:
- `minDate` = today (can't book in the past)
- `maxDate` = today + 30 days (restaurant's booking window)

Dates outside this range are grayed out and unselectable.

### Why `.onChange(of: viewModel.selectedDate)` to reload time slots?

When the user picks a different date, available time slots change (different days have different availability). `.onChange` fires whenever `selectedDate` changes, triggering a fresh fetch of time slots for the new date.

---

### `RestaurantInfoView.swift`

```swift
@StateObject private var viewModel: RestaurantViewModel = RestaurantViewModel(
    repository: RestaurantRepository()
)
```

### Why `@StateObject` here but `@EnvironmentObject` for other views?

`RestaurantInfoView` creates its own `RestaurantViewModel` directly because:
1. Restaurant info is not shared with other tabs
2. The ViewModel is only needed when this tab is visible
3. It doesn't need to be injected from `DIContainer` because it has no shared state

This is an intentional simplification — not every ViewModel needs to come from the DI container.

### Why `Map(position:)` not `Map(coordinateRegion:)`?

```swift
Map(position: .constant(MapCameraPosition.region(...))) {
    Marker(restaurant.name, coordinate: restaurant.coordinate)
        .tint(AppColors.primary)
}
```

`Map(coordinateRegion:)` was deprecated in iOS 17. The new `Map(position:)` API:
- Uses `MapCameraPosition` which supports more camera types (region, rect, item, user location)
- Supports the new `Marker`, `Annotation`, `MapPolyline` content builders
- Is more composable and future-proof

### Why `.allowsHitTesting(false)` on the map?

```swift
.allowsHitTesting(false)
```

The map is decorative — we don't want the user to interact with it (pan, zoom, tap). `.allowsHitTesting(false)` disables all touch events on the map. The "Directions" button below it opens Maps app for actual navigation.

---

## 10. Presentation Layer — Components

### `MenuItemCard.swift`

```swift
struct MenuItemCard: View {
    let item: MenuItem
    let onAddToCart: () -> Void
    ...
}
```

### Why closure `onAddToCart: () -> Void` not direct ViewModel access?

Passing a closure makes `MenuItemCard` a **pure component** — it has no knowledge of `CartViewModel`. This means:
- The card can be reused in any context (search results, favorites, recommendations)
- The parent view decides what happens when "add" is tapped
- The card is independently previewable without any ViewModel

### `PrimaryButton.swift`

```swift
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
}
```

### Why a dedicated `PrimaryButton` component?

Without it, every button would repeat:
```swift
.font(.headline)
.foregroundColor(.white)
.frame(maxWidth: .infinity)
.frame(height: 50)
.background(isDisabled ? AppColors.textTertiary : AppColors.primary)
.cornerRadius(12)
```

`PrimaryButton` encapsulates this styling once. Changing the app's button style requires editing one file. It also handles the loading state (shows `ProgressView` instead of text) consistently everywhere.

### `LoadingView.swift` — Four components for different loading contexts

| Component | Use Case |
|-----------|----------|
| `LoadingView` | Full-screen loading (first data fetch) |
| `LoadingOverlay` | Blocking overlay during async action (placing order) |
| `ShimmerView` | Animated placeholder for individual cells |
| `SkeletonCard` | Placeholder card matching `MenuItemCard` layout |

Using skeleton cards (`SkeletonCard`) instead of a spinner for list loading is better UX — the user sees the layout before data arrives, reducing perceived loading time.

### `QuantitySelector.swift` — Two variants

```swift
struct QuantitySelector: View {       // inline, compact, uses callback
    let quantity: Int
    let onQuantityChanged: (Int) -> Void
}

struct LargeQuantitySelector: View {  // full-width, uses @Binding
    @Binding var quantity: Int
    var label: String = "Quantity"
}
```

### Why two variants — callback vs `@Binding`?

| Variant | Used In | Why |
|---------|---------|-----|
| `QuantitySelector` (callback) | `CartItemRow` | Cart item quantity is managed by ViewModel, not local state |
| `LargeQuantitySelector` (@Binding) | `MenuItemDetailView`, `ReservationFormView` | Local form state, no ViewModel involved |

`CartItemRow` uses a callback because changing quantity triggers an async ViewModel action (updates the repository). `MenuItemDetailView` uses `@Binding` because the quantity is just local form state before the user taps "Add to Cart."

### `TimeSlotPicker.swift`

```swift
struct TimeSlotPicker: View {
    let slots: [TimeSlot]
    @Binding var selectedTime: String?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()),
                           GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) { ... }
    }
}
```

### Why `LazyVGrid` with 4 columns?

Time slots are short strings like "11:00", "11:30". A 4-column grid fits them compactly on iPhone screens. `LazyVGrid` only renders visible cells — if there are 24 time slots, only the visible ones are rendered, improving performance.

### Why `@Binding var selectedTime: String?` not a callback?

The selected time is form state that `ReservationFormView` needs to read (to enable the confirm button). `@Binding` creates a two-way connection — `TimeSlotPicker` writes the selection, `ReservationFormView` reads it. A callback would only notify of changes without giving the parent direct access to the current value.

---

## 11. Core — Constants & Extensions

### `AppConstants.swift` — Why nested enums?

```swift
enum AppConstants {
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
    }
    enum Cart {
        static let maxQuantity = 99
    }
}
```

Using `enum` (not `struct` or `class`) for constants:
- `enum` with no cases cannot be instantiated — it's a pure namespace
- Nested enums group related constants (`AppConstants.Layout.cornerRadius`)
- Changing `cornerRadius` in one place updates all cards, buttons, and sheets

### `ColorConstants.swift` — Why `AppColors` enum + `Color` extension?

```swift
enum AppColors {
    static let primary = Color(hex: "E85D04")
}

extension Color {
    static let appPrimary = Color("Primary")  // from Assets.xcassets
}
```

Two approaches serve different needs:
- `AppColors.primary` — hardcoded hex, always available, used in code
- `Color("Primary")` — from Asset Catalog, supports dark mode variants

The `Color(hex:)` extension converts hex strings to `Color` without external libraries.

### `View+Extensions.swift` — Why `.if()` modifier?

```swift
func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition { transform(self) } else { self }
}
```

This enables conditional modifier application:
```swift
Text("Hello")
    .if(isHighlighted) { $0.bold().foregroundColor(.red) }
```

Without this, you'd need:
```swift
if isHighlighted {
    Text("Hello").bold().foregroundColor(.red)
} else {
    Text("Hello")
}
```

The `.if()` modifier avoids duplicating the view.

### `Double+Currency.swift`

```swift
extension Double {
    var asCurrency: String { ... }      // "$12.99" via NumberFormatter
    var asCompactCurrency: String { ... } // "$12.99" via String(format:)
}
```

### Why two currency formatters?

`asCurrency` uses `NumberFormatter` which respects locale (€12,99 in Europe). `asCompactCurrency` uses `String(format:)` which always produces `$12.99`. The app currently uses `asCompactCurrency` everywhere for consistency, but `asCurrency` is ready for localization.

---

## 12. End-to-End App Flow

### App Launch

```
restaurantApp.init()
    └── @StateObject DIContainer() created
            └── mockDataSource = MockDataSource.shared (singleton)
            └── All repositories/use cases: NOT YET CREATED (lazy)
    └── MainTabView() shown
            └── .environmentObject(container) injected
```

### User Opens Menu Tab (First Time)

```
MainTabView appears
    └── container.sharedCartViewModel created (lazy, first access)
    └── MenuView(cartViewModel: sharedCartViewModel) created
    └── MenuView.task fires
            └── viewModel = container.makeMenuViewModel()
                    └── getCategoriesUseCase created (lazy)
                    └── menuRepository created (lazy)
                    └── MockDataSource.shared accessed
            └── viewModel.loadInitialData() called
                    └── isLoading = true → SkeletonCard shown
                    └── getCategoriesUseCase.execute()
                            └── menuRepository.getCategories()
                                    └── Task.sleep(200-500ms) — simulated delay
                                    └── mockDataSource.categories returned
                    └── categories = [Appetizers, Salads, Pasta, Pizza, Mains, Desserts, Drinks]
                    └── selectCategory(categories.first) → Appetizers selected
                            └── getMenuItemsUseCase.execute(categoryId: "cat-001")
                                    └── mockDataSource.menuItems.filter { $0.categoryId == "cat-001" }
                                    └── Returns 6 appetizer items
                    └── isLoading = false → MenuItemCard list shown
```

### User Taps a Menu Item

```
MenuItemCard.onTapGesture
    └── selectedItem = item
    └── showingItemDetail = true
    └── Sheet presented: MenuItemDetailView(item:, cartViewModel:)
            └── User adjusts quantity (LargeQuantitySelector @Binding)
            └── User types special instructions (TextField)
            └── User taps "Add to Cart"
                    └── cartViewModel.addToCart(item, quantity: 2, specialInstructions: "No onions")
                            └── addToCartUseCase.execute(item:, quantity:, specialInstructions:)
                                    └── guard quantity > 0 ✅
                                    └── cartRepository.addToCart(...)
                                            └── actor CartRepository
                                            └── var updated = cart
                                            └── updated.addItem(item, quantity: 2)
                                            └── cart = updated
                                    └── Returns updated Cart
                            └── cartViewModel.cart updated → @Published fires
                            └── CartView badge updates: 2
                    └── Toast "Added to cart!" shown for 1.5s
                    └── Sheet dismissed
```

### User Opens Cart Tab

```
CartView(viewModel: sharedCartViewModel) — same instance as MenuView
    └── cart.items = [CartItem(Bruschetta x2, "No onions")]
    └── CartItemRow shown with quantity selector
    └── Price summary: Subtotal $17.98, Tax $1.62, Total $19.60
    └── User enters promo code "WELCOME10"
            └── cartViewModel.applyPromoCode()
                    └── applyPromoCodeUseCase.execute(code: "WELCOME10")
                            └── cartRepository.applyPromoCode("WELCOME10")
                                    └── validPromoCodes["WELCOME10"] = 0.10
                                    └── promoDiscount = 17.98 * 0.10 = $1.80
                    └── cart.promoCode = "WELCOME10", promoDiscount = $1.80
            └── Price summary updates: Subtotal $17.98, Discount -$1.80, Tax $1.46, Total $17.64
    └── User taps "Proceed to Checkout"
            └── showingCheckout = true → CheckoutView sheet
```

### User Places Order

```
CheckoutView
    └── User selects "Pickup"
    └── User taps "Place Order - $17.64"
            └── cartViewModel.placeOrder()
                    └── isPlacingOrder = true → LoadingOverlay shown
                    └── placeOrderUseCase.execute(cart:, orderType: .pickup, ...)
                            └── guard !cart.isEmpty ✅
                            └── orderRepository.placeOrder(...)
                                    └── Task.sleep(500ms)
                                    └── Order created with status: .confirmed
                                    └── estimatedReadyTime = now + 25 minutes
                                    └── orders.insert(order, at: 0)
                            └── cartRepository.clearCart()
                                    └── cart = Cart() (empty)
                    └── lastPlacedOrder = order
                    └── cart = Cart() (empty)
                    └── showingCheckout = false
                    └── showingOrderConfirmation = true
                    └── isPlacingOrder = false
            └── OrderConfirmationView shown
                    └── "Order Confirmed!" ✅
                    └── Order #ABC12345, Pickup, Ready at 1:45 PM, $17.64
    └── Cart tab badge: 0
```

### User Makes a Reservation

```
ReservationView.task
    └── viewModel = container.makeReservationViewModel()
    └── viewModel.loadReservations() → empty list
    └── "No Reservations" EmptyStateView shown
    └── User taps "+" toolbar button
            └── ReservationFormView sheet presented
                    └── DatePicker: user selects tomorrow
                    └── .onChange fires → viewModel.loadAvailableSlots()
                            └── getAvailableSlotsUseCase.execute(date:, partySize: 2)
                                    └── guard partySize > 0 ✅
                                    └── reservationRepository.getAvailableSlots(...)
                                            └── Task.sleep(400ms)
                                            └── generateTimeSlots(for: date)
                                            └── Returns ~22 slots, some available/unavailable
                    └── TimeSlotPicker shown with 4-column grid
                    └── User taps "19:00" (available)
                            └── selectedTime = "19:00"
                    └── User fills: Name "John Doe", Phone "555-1234"
                    └── "Confirm Reservation" button enabled (canMakeReservation = true)
                    └── User taps confirm
                            └── viewModel.makeReservation()
                                    └── makeReservationUseCase.execute(...)
                                            └── Validation: partySize > 0 ✅
                                            └── Validation: date >= today ✅
                                            └── Validation: name/phone not empty ✅
                                            └── reservationRepository.makeReservation(...)
                                                    └── confirmationCode = "ABC123"
                                                    └── Reservation created, status: .confirmed
                            └── showingConfirmation = true
                    └── ReservationConfirmationView shown
                            └── "Reservation Confirmed!" ✅
                            └── Code: ABC123
```

---

## 13. Swift Concurrency Patterns Used

### `async/await` — Linear async code

```swift
// Old callback style
repository.getCategories { result in
    switch result {
    case .success(let categories): ...
    case .failure(let error): ...
    }
}

// New async/await style
let categories = try await repository.getCategories()
```

`async/await` makes asynchronous code read like synchronous code. Errors propagate naturally via `throws`.

### `actor` — Thread-safe mutable state

```swift
actor CartRepository {
    private var cart: Cart = Cart()  // protected by actor

    func addToCart(...) async throws -> Cart {
        var updated = cart           // safe read
        updated.addItem(...)         // mutate copy
        cart = updated               // safe write
        return cart
    }
}
```

The actor runtime ensures only one task accesses `cart` at a time. No locks, no `DispatchQueue.sync`, no data races.

### `Task.sleep` — Non-blocking delay

```swift
try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds
```

Unlike `Thread.sleep` (blocks the thread), `Task.sleep` suspends the current task and frees the thread for other work. The thread is not blocked.

### Structured concurrency with `.task { }`

```swift
.task {
    await viewModel.loadInitialData()
}
```

The task is automatically cancelled when the view disappears. If the user switches tabs before loading completes, the in-flight request is cancelled, preventing memory leaks and unnecessary processing.

---

## 14. Design Decisions & Comparisons

### Why Clean Architecture over simple MVVM?

| Aspect | Simple MVVM | Clean Architecture + MVVM |
|--------|-------------|--------------------------|
| ViewModel size | Grows large (networking + business logic + UI state) | Small (only UI state + use case calls) |
| Testing | Hard (ViewModel has direct network calls) | Easy (mock use cases, mock repositories) |
| Swapping API | Touch ViewModel | Touch only Repository |
| Adding feature | Risk breaking existing features | Add new use case, new repository method |
| Onboarding | Read one large file | Read small, focused files |

### Why not TCA (The Composable Architecture)?

TCA is excellent for complex apps but adds significant overhead:
- External dependency (not native Swift)
- Steep learning curve
- More boilerplate for simple features
- Overkill for a restaurant app of this size

### Why not VIPER?

VIPER was designed for UIKit. In SwiftUI, the Presenter and Router layers become awkward because SwiftUI handles navigation and view updates natively. Clean Architecture + MVVM maps more naturally to SwiftUI's data flow.

### Why `struct` entities not `class`?

```swift
// struct — value type
var item1 = MenuItem(name: "Bruschetta", price: 8.99)
var item2 = item1
item2.price = 10.00
// item1.price is still 8.99 ✅

// class — reference type
var item1 = MenuItem(name: "Bruschetta", price: 8.99)
var item2 = item1
item2.price = 10.00
// item1.price is now 10.00 ❌ (unexpected mutation)
```

Value types prevent accidental shared mutation. In a multi-threaded app, two threads reading the same struct each get their own copy — no race conditions.

### Why `Sendable` on protocols?

Swift 6 strict concurrency requires that types crossing actor boundaries are `Sendable`. Marking repository protocols as `Sendable` future-proofs the code for Swift 6 and prevents runtime concurrency warnings.

### Why hex colors not Asset Catalog colors?

`AppColors` uses hardcoded hex values for simplicity during development. Asset Catalog colors (`Color("Primary")`) support dark mode variants but require Xcode to manage. The hex approach is faster to iterate on and easier to read in code. The `Color` extension on `AppColors` can be replaced with Asset Catalog colors when dark mode support is added.

### Why `enum` for `AppConstants` not `struct`?

```swift
enum AppConstants { ... }  // cannot be instantiated
struct AppConstants { ... } // can be instantiated (AppConstants())
```

Using `enum` prevents `AppConstants()` from being written anywhere. Constants are accessed as `AppConstants.Layout.cornerRadius` — the type is a pure namespace, not a value.
