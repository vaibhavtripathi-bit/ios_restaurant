# iOS Restaurant App

A modern iOS restaurant ordering application built with Swift and SwiftUI following Clean Architecture principles.

## Features

- Restaurant browsing and discovery
- Menu viewing with item details
- Shopping cart management
- Order placement and tracking
- User authentication

## Architecture

The app follows **Clean Architecture** with clear separation of concerns:

```
restaurant/
├── App/              # App entry point and configuration
├── Core/             # Core utilities and extensions
├── Data/             # Data layer (repositories, data sources, DTOs)
├── Domain/           # Business logic (entities, use cases, interfaces)
├── Presentation/     # UI layer (views, view models)
└── Resources/        # Assets, localization, etc.
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Domain** | Business entities, use cases, repository interfaces |
| **Data** | Repository implementations, API clients, local storage |
| **Presentation** | SwiftUI views, view models, UI state management |

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: Clean Architecture + MVVM
- **Dependency Injection**: Manual DI
- **Networking**: URLSession / Async-Await

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Getting Started

1. Clone the repository
2. Open `restaurant/restaurant.xcodeproj` in Xcode
3. Select a simulator or device
4. Build and run (⌘R)

## Project Structure

```
ios_restaurant/
├── restaurant/
│   ├── restaurant/           # Main app source
│   ├── restaurant.xcodeproj  # Xcode project
│   ├── restaurantTests/      # Unit tests
│   └── restaurantUITests/    # UI tests
└── docs/                     # Documentation
```

## Testing

- **Unit Tests**: Located in `restaurantTests/`
- **UI Tests**: Located in `restaurantUITests/`

Run tests with ⌘U in Xcode.

## License

MIT License
