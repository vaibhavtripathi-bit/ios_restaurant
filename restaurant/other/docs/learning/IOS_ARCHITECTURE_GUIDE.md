# iOS Clean Architecture + MVVM Guide

## Overview

This guide explains the architecture used in the Restaurant iOS app and how to work with it effectively.

## Understanding the Layers

### 1. Domain Layer (Core Business)

The Domain layer is the heart of the application. It contains:

#### Entities
Pure Swift models representing business objects.

```swift
struct MenuItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let description: String
}
```

**Rules:**
- No dependencies on other layers
- No UIKit/SwiftUI imports
- Immutable when possible (use `let`)

#### Use Cases
Single-purpose classes that execute business operations.

```swift
protocol GetMenuUseCaseProtocol {
    func execute(categoryId: String) async throws -> [MenuItem]
}

final class GetMenuUseCase: GetMenuUseCaseProtocol {
    private let repository: MenuRepositoryProtocol
    
    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(categoryId: String) async throws -> [MenuItem] {
        return try await repository.getMenuItems(for: categoryId)
    }
}
```

**Rules:**
- One public method: `execute()`
- Inject repositories via constructor
- Use protocols for dependencies

#### Repository Protocols
Abstractions that define data operations.

```swift
protocol MenuRepositoryProtocol {
    func getCategories() async throws -> [Category]
    func getMenuItems(for categoryId: String) async throws -> [MenuItem]
}
```

**Why protocols?**
- Allows swapping implementations (mock vs real API)
- Enables unit testing with mocks
- Domain doesn't know about data sources

---

### 2. Data Layer (Data Access)

The Data layer implements repository protocols and handles data retrieval.

#### Repository Implementations
```swift
final class MenuRepository: MenuRepositoryProtocol {
    private let dataSource: MenuDataSourceProtocol
    
    init(dataSource: MenuDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func getMenuItems(for categoryId: String) async throws -> [MenuItem] {
        let dtos = try await dataSource.fetchMenuItems(categoryId: categoryId)
        return dtos.map { $0.toDomain() }
    }
}
```

#### Data Sources
Handle actual data fetching (API, local storage).

```swift
protocol MenuDataSourceProtocol {
    func fetchMenuItems(categoryId: String) async throws -> [MenuItemDTO]
}

final class MockMenuDataSource: MenuDataSourceProtocol {
    func fetchMenuItems(categoryId: String) async throws -> [MenuItemDTO] {
        // Return mock data
    }
}
```

#### DTOs (Data Transfer Objects)
Match the structure of external data (API responses).

```swift
struct MenuItemDTO: Codable {
    let id: String
    let name: String
    let price: Double
    
    func toDomain() -> MenuItem {
        MenuItem(id: id, name: name, price: price)
    }
}
```

---

### 3. Presentation Layer (UI)

The Presentation layer handles everything the user sees and interacts with.

#### ViewModels
Manage state and coordinate with use cases.

```swift
@Observable
final class MenuViewModel {
    private(set) var items: [MenuItem] = []
    private(set) var isLoading = false
    private(set) var error: String?
    
    private let getMenuUseCase: GetMenuUseCaseProtocol
    
    init(getMenuUseCase: GetMenuUseCaseProtocol) {
        self.getMenuUseCase = getMenuUseCase
    }
    
    func loadMenu(categoryId: String) async {
        isLoading = true
        error = nil
        
        do {
            items = try await getMenuUseCase.execute(categoryId: categoryId)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

**Modern iOS 17+ Pattern:**
- Use `@Observable` macro instead of `ObservableObject`
- No need for `@Published` - all properties auto-tracked
- Cleaner, less boilerplate

#### Views
SwiftUI views that render UI based on ViewModel state.

```swift
struct MenuView: View {
    @State private var viewModel: MenuViewModel
    
    init(viewModel: MenuViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        List(viewModel.items) { item in
            MenuItemCard(item: item)
        }
        .task {
            await viewModel.loadMenu(categoryId: "appetizers")
        }
    }
}
```

#### Reusable Components
Self-contained UI components.

```swift
struct MenuItemCard: View {
    let item: MenuItem
    
    var body: some View {
        HStack {
            // Card content
        }
    }
}
```

---

## Dependency Injection

### Container Pattern

```swift
@Observable
final class AppContainer {
    // Data Sources
    private lazy var menuDataSource: MenuDataSourceProtocol = MockMenuDataSource()
    
    // Repositories
    private lazy var menuRepository: MenuRepositoryProtocol = {
        MenuRepository(dataSource: menuDataSource)
    }()
    
    // Use Cases
    lazy var getMenuUseCase: GetMenuUseCaseProtocol = {
        GetMenuUseCase(repository: menuRepository)
    }()
    
    // ViewModels
    func makeMenuViewModel() -> MenuViewModel {
        MenuViewModel(getMenuUseCase: getMenuUseCase)
    }
}
```

### Using in SwiftUI

```swift
@main
struct RestaurantApp: App {
    @State private var container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(container)
        }
    }
}
```

---

## Adding a New Feature

### Step-by-Step Example: Adding "Favorites"

#### 1. Domain Layer

**Entity:**
```swift
// Domain/Entities/Favorite.swift
struct Favorite: Identifiable {
    let id: String
    let menuItem: MenuItem
    let addedAt: Date
}
```

**Repository Protocol:**
```swift
// Domain/Repositories/FavoriteRepositoryProtocol.swift
protocol FavoriteRepositoryProtocol {
    func getFavorites() async throws -> [Favorite]
    func addFavorite(_ item: MenuItem) async throws
    func removeFavorite(id: String) async throws
}
```

**Use Cases:**
```swift
// Domain/UseCases/Favorites/GetFavoritesUseCase.swift
final class GetFavoritesUseCase {
    private let repository: FavoriteRepositoryProtocol
    
    func execute() async throws -> [Favorite] {
        try await repository.getFavorites()
    }
}
```

#### 2. Data Layer

**Repository Implementation:**
```swift
// Data/Repositories/FavoriteRepository.swift
final class FavoriteRepository: FavoriteRepositoryProtocol {
    // Implementation
}
```

#### 3. Presentation Layer

**ViewModel:**
```swift
// Presentation/ViewModels/FavoritesViewModel.swift
@Observable
final class FavoritesViewModel {
    // State and methods
}
```

**View:**
```swift
// Presentation/Views/Favorites/FavoritesView.swift
struct FavoritesView: View {
    // UI
}
```

---

## Best Practices

### Do's ✅
- Keep entities immutable
- One use case = one operation
- Use protocols for all dependencies
- Keep ViewModels focused on one screen
- Extract reusable UI into components

### Don'ts ❌
- Don't import UIKit/SwiftUI in Domain layer
- Don't access repositories directly from ViewModels
- Don't put business logic in Views
- Don't skip the DTO → Entity mapping
- Don't use singletons for dependencies

---

## Testing Strategy

### Unit Testing Layers

| Layer | What to Test | How |
|-------|-------------|-----|
| Domain | Use Cases | Mock repositories |
| Data | Repositories | Mock data sources |
| Presentation | ViewModels | Mock use cases |

### Example Test

```swift
final class GetMenuUseCaseTests: XCTestCase {
    func testExecuteReturnsItems() async throws {
        // Given
        let mockRepo = MockMenuRepository()
        mockRepo.itemsToReturn = [MenuItem.mock()]
        let useCase = GetMenuUseCase(repository: mockRepo)
        
        // When
        let items = try await useCase.execute(categoryId: "test")
        
        // Then
        XCTAssertEqual(items.count, 1)
    }
}
```
