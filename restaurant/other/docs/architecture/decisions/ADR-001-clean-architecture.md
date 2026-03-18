# ADR-001: Clean Architecture + MVVM

## Status
**Accepted** - March 16, 2026

## Context

We need to choose an architecture pattern for the Restaurant iOS app that:
1. Supports code reusability across features
2. Makes the codebase easy to understand for developers
3. Allows for easy testing
4. Scales well as features are added
5. Uses modern iOS development patterns

### Options Considered

#### Option 1: Simple MVVM
**Pros:**
- Simple to implement
- Works well with SwiftUI
- Less boilerplate

**Cons:**
- ViewModels can become bloated
- Business logic mixed with presentation logic
- Harder to test in isolation
- Doesn't scale well

#### Option 2: Clean Architecture + MVVM
**Pros:**
- Clear separation of concerns
- Business logic isolated in use cases
- Highly testable
- Scales well
- Repository pattern allows easy data source swapping

**Cons:**
- More initial boilerplate
- Learning curve for new developers

#### Option 3: The Composable Architecture (TCA)
**Pros:**
- Very structured state management
- Excellent for complex state
- Great testing story

**Cons:**
- External dependency
- Steep learning curve
- Overkill for this app size

#### Option 4: VIPER
**Pros:**
- Very modular
- Clear responsibilities

**Cons:**
- Excessive boilerplate
- Designed for UIKit, not SwiftUI
- Hard to understand for newcomers

## Decision

We will use **Clean Architecture + MVVM** because:

1. **Right balance** - Provides structure without excessive boilerplate
2. **SwiftUI compatible** - MVVM maps naturally to SwiftUI's data flow
3. **Use Cases** - Business logic in use cases makes code self-documenting
4. **Testability** - Each layer can be tested independently
5. **No external dependencies** - Uses only native iOS frameworks
6. **Future-proof** - Easy to swap data sources (mock → real API)

## Consequences

### Positive
- Clear code organization from day one
- Easy onboarding for new developers
- Business logic can be reused
- Data layer can be swapped without touching UI
- Each feature follows the same pattern

### Negative
- More files than simple MVVM
- Initial setup takes longer
- Developers need to understand the layer boundaries

### Mitigations
- Provide clear documentation
- Use consistent naming conventions
- Create templates for new features

## Implementation Notes

### Layer Rules

1. **Domain Layer** (innermost)
   - Contains entities and use cases
   - Has NO dependencies on other layers
   - Defines repository protocols (abstractions)

2. **Data Layer**
   - Implements repository protocols
   - Contains data sources and DTOs
   - Depends only on Domain layer

3. **Presentation Layer** (outermost)
   - Contains Views and ViewModels
   - Depends on Domain layer (use cases)
   - Never directly accesses Data layer

### Dependency Direction

```
Presentation → Domain ← Data
```

All dependencies point toward the Domain layer.
