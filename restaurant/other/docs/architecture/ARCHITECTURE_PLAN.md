# Restaurant iOS App - Architecture Plan

## Overview

A modern iOS restaurant application built with SwiftUI and Clean Architecture + MVVM pattern. The app allows users to browse menus, place orders, make reservations, and manage their account.

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Swift | 5.9+ | Programming language |
| SwiftUI | iOS 17+ | UI Framework |
| Observation | iOS 17+ | State management (replaces @ObservableObject) |
| Swift Concurrency | async/await | Asynchronous operations |
| SwiftData | iOS 17+ | Local persistence (optional) |

## Architecture: Clean Architecture + MVVM

### Why This Architecture?

1. **Separation of Concerns** - Each layer has a single responsibility
2. **Testability** - Business logic is isolated and easily testable
3. **Scalability** - Easy to add new features without affecting existing code
4. **Reusability** - Components and use cases can be reused across features
5. **Maintainability** - Clear boundaries make code easier to understand and modify

### Layer Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Views     │──│ ViewModels  │──│  UI Components      │  │
│  │  (SwiftUI)  │  │ (@Observable)│  │  (Reusable)        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │ Repository Protocols│  │
│  │  (Models)   │  │  (Business) │  │   (Abstractions)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │Repositories │  │ Data Sources│  │       DTOs          │  │
│  │  (Impl)     │  │(Remote/Local)│  │ (Data Transfer)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → View → ViewModel → UseCase → Repository → DataSource
                                                            │
User sees ← View ← ViewModel ← UseCase ← Repository ←───────┘
```

## Project Structure

```
RestaurantApp/
├── App/
│   ├── RestaurantAppApp.swift          # App entry point
│   └── AppContainer.swift              # Dependency injection container
│
├── Domain/
│   ├── Entities/
│   │   ├── MenuItem.swift              # Menu item model
│   │   ├── Category.swift              # Menu category model
│   │   ├── CartItem.swift              # Shopping cart item
│   │   ├── Order.swift                 # Order model
│   │   ├── Reservation.swift           # Reservation model
│   │   ├── Restaurant.swift            # Restaurant info model
│   │   └── User.swift                  # User model
│   │
│   ├── UseCases/
│   │   ├── Menu/
│   │   │   ├── GetMenuUseCase.swift
│   │   │   └── GetCategoriesUseCase.swift
│   │   ├── Cart/
│   │   │   ├── AddToCartUseCase.swift
│   │   │   ├── RemoveFromCartUseCase.swift
│   │   │   └── GetCartUseCase.swift
│   │   ├── Order/
│   │   │   ├── PlaceOrderUseCase.swift
│   │   │   └── GetOrderHistoryUseCase.swift
│   │   └── Reservation/
│   │       ├── MakeReservationUseCase.swift
│   │       └── GetAvailableSlotsUseCase.swift
│   │
│   └── Repositories/
│       ├── MenuRepositoryProtocol.swift
│       ├── CartRepositoryProtocol.swift
│       ├── OrderRepositoryProtocol.swift
│       └── ReservationRepositoryProtocol.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── MenuRepository.swift
│   │   ├── CartRepository.swift
│   │   ├── OrderRepository.swift
│   │   └── ReservationRepository.swift
│   │
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   └── APIClient.swift
│   │   └── Local/
│   │       └── MockDataSource.swift    # Mock data for development
│   │
│   └── DTOs/
│       ├── MenuItemDTO.swift
│       └── OrderDTO.swift
│
├── Presentation/
│   ├── Views/
│   │   ├── Main/
│   │   │   └── MainTabView.swift       # Main tab navigation
│   │   ├── Menu/
│   │   │   ├── MenuView.swift          # Menu listing
│   │   │   └── MenuItemDetailView.swift
│   │   ├── Cart/
│   │   │   ├── CartView.swift
│   │   │   └── CheckoutView.swift
│   │   ├── Reservation/
│   │   │   └── ReservationView.swift
│   │   ├── Profile/
│   │   │   └── ProfileView.swift
│   │   └── Restaurant/
│   │       └── RestaurantInfoView.swift
│   │
│   ├── ViewModels/
│   │   ├── MenuViewModel.swift
│   │   ├── CartViewModel.swift
│   │   ├── ReservationViewModel.swift
│   │   └── ProfileViewModel.swift
│   │
│   └── Components/
│       ├── MenuItemCard.swift          # Reusable menu item card
│       ├── CartItemRow.swift           # Cart item row
│       ├── PrimaryButton.swift         # Styled primary button
│       ├── QuantitySelector.swift      # +/- quantity picker
│       ├── CategoryPill.swift          # Category filter pill
│       ├── PriceTag.swift              # Price display component
│       ├── RatingView.swift            # Star rating display
│       ├── LoadingView.swift           # Loading indicator
│       └── EmptyStateView.swift        # Empty state placeholder
│
├── Core/
│   ├── DI/
│   │   └── DIContainer.swift           # Dependency injection
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── Double+Currency.swift
│   ├── Constants/
│   │   ├── AppConstants.swift
│   │   └── ColorConstants.swift
│   └── Utilities/
│       └── ImageLoader.swift           # Async image loading
│
└── Resources/
    ├── Assets.xcassets/
    │   ├── Colors/
    │   └── Images/
    └── Preview Content/
```

## Features

### 1. Menu Browsing
- View menu items by category
- Search functionality
- Filter by dietary preferences (vegetarian, vegan, gluten-free)
- View item details with images and descriptions

### 2. Shopping Cart
- Add/remove items
- Adjust quantities
- Special instructions per item
- Real-time price calculation
- Promo code support

### 3. Checkout
- Order summary
- Delivery/pickup selection
- Payment method selection (UI only)
- Order confirmation

### 4. Reservations
- Date and time selection
- Party size
- Special requests
- Confirmation

### 5. Restaurant Info
- Location with map
- Operating hours
- Contact information
- About section

### 6. User Profile
- View order history
- Saved favorites
- Account settings

## Design Principles

### 1. Reusability
- All UI components are modular and reusable
- Use cases are single-purpose and composable
- ViewModels are feature-specific but share common patterns

### 2. Readability
- Clear naming conventions
- Comprehensive documentation
- Consistent code structure across features

### 3. Modern iOS Patterns
- `@Observable` macro (iOS 17+) instead of `ObservableObject`
- Async/await for all asynchronous operations
- Swift Concurrency with structured concurrency
- Environment-based dependency injection

### 4. Type Safety
- Strong typing throughout
- No force unwrapping
- Comprehensive error handling

## Color Scheme

| Color | Usage | Hex |
|-------|-------|-----|
| Primary | Buttons, accents | #E85D04 (Orange) |
| Secondary | Secondary actions | #F48C06 |
| Background | Main background | #FFFFFF |
| Surface | Cards, containers | #F8F9FA |
| Text Primary | Main text | #212529 |
| Text Secondary | Subtitles | #6C757D |
| Success | Success states | #28A745 |
| Error | Error states | #DC3545 |

## Dependencies

### Native Only (No External Dependencies)
This project uses only native iOS frameworks:
- SwiftUI
- Foundation
- Observation
- MapKit (for restaurant location)

## Future Enhancements

- [ ] Push notifications for order updates
- [ ] Apple Pay integration
- [ ] Loyalty points system
- [ ] Social sharing
- [ ] Dark mode support
- [ ] Localization

## Related Documents

- [ADR-001: Clean Architecture Decision](./decisions/ADR-001-clean-architecture.md)
- [API Documentation](../api/endpoints.md)
