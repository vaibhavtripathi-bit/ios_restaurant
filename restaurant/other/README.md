# La Bella Italia - Restaurant iOS App

A modern iOS restaurant application built with SwiftUI and Clean Architecture + MVVM pattern.

## Features

- **Menu Browsing**: Browse menu items by category with search functionality
- **Shopping Cart**: Add items, adjust quantities, apply promo codes
- **Checkout**: Place orders for pickup, delivery, or dine-in
- **Reservations**: Book a table with date/time selection
- **Restaurant Info**: View location, hours, contact information
- **Profile**: View order history and account information

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Swift | 5.9+ | Programming language |
| SwiftUI | iOS 17+ | UI Framework |
| Observation | iOS 17+ | State management |
| Swift Concurrency | async/await | Asynchronous operations |
| MapKit | - | Location display |

## Architecture

This app uses **Clean Architecture + MVVM**:

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
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │Repositories │  │ Data Sources│  │       DTOs          │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
RestaurantApp/
├── App/                      # App entry point & DI container
├── Domain/                   # Business logic layer
│   ├── Entities/             # Business models
│   ├── UseCases/             # Business operations
│   └── Repositories/         # Repository protocols
├── Data/                     # Data access layer
│   ├── Repositories/         # Repository implementations
│   └── DataSources/          # Data sources (mock/API)
├── Presentation/             # UI layer
│   ├── Views/                # SwiftUI views
│   ├── ViewModels/           # View models
│   └── Components/           # Reusable UI components
├── Core/                     # Shared utilities
│   ├── DI/                   # Dependency injection
│   ├── Extensions/           # Swift extensions
│   └── Constants/            # App constants
└── Resources/                # Assets and resources
```

## Setup Instructions

### Step-by-Step Xcode Setup

1. **Open Xcode 15+** and select **Create New Project**

2. **Choose template:**
   - Platform: iOS
   - Application: App
   - Click **Next**

3. **Configure project:**
   - Product Name: `RestaurantApp`
   - Organization Identifier: `com.restaurant` (or your own)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Click **Next**

4. **Save location:**
   - Save it in a **temporary location** (e.g., Desktop)
   - Uncheck "Create Git repository"
   - Click **Create**

5. **Delete default files:**
   - In Xcode's Project Navigator, delete `ContentView.swift`
   - Select "Move to Trash"

6. **Add source files:**
   - Right-click on `RestaurantApp` folder in Project Navigator
   - Select **Add Files to "RestaurantApp"...**
   - Navigate to this project's `RestaurantApp/` folder
   - Select ALL folders inside: `App`, `Core`, `Data`, `Domain`, `Presentation`, `Resources`
   - **IMPORTANT:** Uncheck "Copy items if needed"
   - Check "Create folder references" 
   - Click **Add**

7. **Set deployment target:**
   - Click on the project (blue icon) in Navigator
   - Under "Minimum Deployments", set iOS to **17.0**

8. **Build and Run!** (⌘ + R)

## Available Promo Codes (Mock Data)

- `WELCOME10` - 10% off
- `SAVE20` - 20% off
- `FREESHIP` - $5 off

## Documentation

- [Architecture Plan](docs/architecture/ARCHITECTURE_PLAN.md)
- [Architecture Decision Record](docs/architecture/decisions/ADR-001-clean-architecture.md)
- [API Documentation](docs/api/endpoints.md)
- [iOS Architecture Guide](docs/learning/IOS_ARCHITECTURE_GUIDE.md)

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## License

This project is for educational purposes.
