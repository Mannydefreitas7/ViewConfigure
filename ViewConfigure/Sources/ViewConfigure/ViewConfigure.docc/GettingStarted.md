# Getting Started

Learn how to integrate and use ViewConfigure in your SwiftUI applications.

## Overview

ViewConfigure provides three main ways to configure your SwiftUI views, each with its own advantages depending on your use case and coding style preferences.

## Installation

### Swift Package Manager

Add ViewConfigure to your project using Swift Package Manager:

1. Open your Xcode project
2. Go to **File > Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/your-username/ViewConfigure.git`
4. Select the version you want to use
5. Click **Add Package**
6. Select the target where you want to add ViewConfigure

### Import the Framework

Once installed, import ViewConfigure in your Swift files:

```swift
import SwiftUI
import ViewConfigure
```

## Configuration Methods

ViewConfigure offers three different approaches to configure your views:

### 1. The Configure Method

The most straightforward approach uses the `configure` method directly on any view:

```swift
Text("Hello, World!")
    .configure(
        listeners: [
            AnyListener(TapListener { print("Tapped!") })
        ],
        stores: [
            AnyStore(UserPreferencesStore())
        ],
        styles: [
            AnyStyle(PaddingStyle(length: 16)),
            AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8))
        ]
    )
```

**Best for**: Simple configurations with a few components.

### 2. The Builder Pattern

For more complex configurations, use the `ViewConfigurator` builder pattern:

```swift
Text("Hello, World!")
    .configured { configurator in
        configurator
            .addStyle(PaddingStyle(length: 16))
            .addStyle(BackgroundStyle(color: .blue, cornerRadius: 8))
            .addStyle(ForegroundColorStyle(color: .white))
            .addListener(TapListener { print("Tapped!") })
            .addStore(UserPreferencesStore())
    }
```

**Best for**: Complex configurations where you need more control over the building process.

### 3. The Result Builder

Use Swift's result builder syntax for the most declarative approach:

```swift
Text("Hello, World!")
    .configured {
        style(PaddingStyle(length: 16))
        style(BackgroundStyle(color: .blue, cornerRadius: 8))
        style(ForegroundColorStyle(color: .white))
        listener(TapListener { print("Tapped!") })
        store(UserPreferencesStore())
    }
```

**Best for**: Clean, readable configurations that feel natural in SwiftUI.

## Your First Configuration

Let's create a simple example that demonstrates all three core concepts:

```swift
import SwiftUI
import ViewConfigure

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .configured {
                    style(FontStyle(font: .largeTitle, weight: .bold))
                    style(ForegroundColorStyle(color: .primary))
                }
            
            Button("Get Started") {
                // Button action
            }
            .configured {
                style(PaddingStyle(length: 16))
                style(BackgroundStyle(color: .blue, cornerRadius: 12))
                style(ForegroundColorStyle(color: .white))
                listener(TapListener { 
                    print("Getting started!") 
                })
            }
        }
        .configured {
            style(PaddingStyle(length: 32))
        }
    }
}
```

## Next Steps

Now that you have ViewConfigure set up, explore these topics:

- **<doc:Protocols>**: Learn about the core protocols that power ViewConfigure
- **<doc:Listeners>**: Discover built-in event handlers for user interactions
- **<doc:Styles>**: Explore visual modifiers for styling your views
- **<doc:Stores>**: Understand how to manage state with observable stores
- **<doc:CreatingCustomComponents>**: Create your own custom listeners, styles, and stores

## Common Patterns

### Reusable Style Combinations

Create reusable style combinations for consistent UI:

```swift
extension Array where Element == AnyStyle {
    static var primaryButton: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(horizontal: 24, vertical: 12)),
            AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8)),
            AnyStyle(ForegroundColorStyle(color: .white)),
            AnyStyle(FontStyle(font: .body, weight: .semibold))
        ]
    }
    
    static var card: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 16)),
            AnyStyle(BackgroundStyle(color: .secondary.opacity(0.1), cornerRadius: 12)),
            AnyStyle(ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2))
        ]
    }
}

// Usage
Button("Submit") { }
    .configure(styles: .primaryButton)

VStack {
    // Card content
}
.configure(styles: .card)
```

### Environment Integration

Use stores to provide shared state across your view hierarchy:

```swift
struct RootView: View {
    var body: some View {
        ContentView()
            .configured {
                store(ThemeStore())
                store(UserPreferencesStore())
            }
    }
}
```

This makes the stores available to all child views through SwiftUI's environment system.
