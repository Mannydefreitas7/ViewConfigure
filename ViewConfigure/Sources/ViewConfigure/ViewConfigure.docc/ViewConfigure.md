# `ViewConfigure`

A Swift package for organizing SwiftUI view configuration with listeners, stores, and styles.

## Overview

ViewConfigure provides a clean and organized way to separate view logic from view styling in SwiftUI applications. It introduces a `configure` method on `View` that allows you to apply various configurations to your views in a declarative way.

The package is built around three core concepts:

- **Listeners**: Event handlers that can be applied to views
- **Stores**: Observable objects that can be injected into the environment
- **Styles**: Visual modifiers that can be applied to views

### Key Features

- **Declarative Configuration**: Apply multiple configurations to views in a single method call
- **Builder Pattern**: Use a fluent API for complex configurations
- **Result Builder**: Leverage Swift's result builder syntax for clean, readable code
- **Type-Safe**: Strongly typed protocols ensure compile-time safety
- **Extensible**: Easy to create custom listeners, stores, and styles
- **Macro Support**: Automatic registration of custom components with the `@Register` macro

## Getting Started

### Installation

Add ViewConfigure to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the package URL: `https://github.com/your-username/ViewConfigure.git`
3. Select the version you want to use
4. Add the package to your target

### Basic Usage

The simplest way to use ViewConfigure is with the `configure` method:

```swift
import SwiftUI
import ViewConfigure

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .configure(
                listeners: [
                    AnyListener(TapListener { print("Tapped!") })
                ],
                styles: [
                    AnyStyle(PaddingStyle(length: 16)),
                    AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8)),
                    AnyStyle(ForegroundColorStyle(color: .white))
                ]
            )
    }
}
```

## Topics

### Essential

- <doc:GettingStarted>
- <doc:Protocols>
- <doc:TypeErasedWrappers>

### Configuration Methods

- <doc:ConfigureMethod>
- <doc:BuilderPattern>
- <doc:ResultBuilder>

### Built-in Components

- <doc:Listeners>
- <doc:Styles>
- <doc:Stores>

### Customization

- <doc:CreatingCustomComponents>
- <doc:RegisterMacro>

### Tutorials

- <doc:BuildingRealWorldExample>

### Advanced Topics

- <doc:BestPractices>
- <doc:Performance>
- <doc:Testing>

## See Also

- `View/configure(listeners:stores:styles:)`
- `View/configured(_:)`
- `ViewConfigurator`
- `ConfigurationBuilder`
