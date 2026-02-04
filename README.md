# ViewConfigure

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-blue.svg)](https://developer.apple.com/swift/)
[![Documentation](https://github.com/Mannydefreitas7/ViewConfigure/workflows/Build%20and%20Deploy%20DocC%20Documentation/badge.svg)](https://mannydefreitas7.github.io/ViewConfigure/documentation/viewconfigure/)
[![Build Status](https://github.com/Mannydefreitas7/ViewConfigure/actions/workflows/docc-build-and-deploy.yml/badge.svg)](https://github.com/Mannydefreitas7/ViewConfigure/actions/workflows/docc-build-and-deploy.yml)

A Swift package for organizing SwiftUI view configuration with listeners, stores, and styles.

`ViewConfigure` provides a clean and organized way to separate view logic from view styling. It introduces a `configure` method on `View` that allows you to apply various configurations to your views in a declarative way.

## Installation

You can add `ViewConfigure` to your project using Swift Package Manager. In Xcode, go to `File > Add Packages...` and enter the following URL:

```
https://github.com/Mannydefreitas7/ViewConfigure.git
```

## Documentation

📚 **[Complete Documentation](https://mannydefreitas7.github.io/ViewConfigure/documentation/viewconfigure/)**

The comprehensive DocC documentation includes:

- Getting started guide with installation and basic usage
- Complete API reference with examples
- Tutorials for creating custom components
- Best practices and performance guidelines
- Real-world examples and patterns

### Building Documentation Locally

To build the documentation locally for development:

```bash
# Interactive preview (rebuilds on changes)
./scripts/build-docs.sh --preview

# Build for local viewing
./scripts/build-docs.sh

# Build for static hosting
./scripts/build-docs.sh --static
```

See [DOCUMENTATION.md](DOCUMENTATION.md) for detailed documentation setup and maintenance instructions.

## Usage

There are three main ways to configure a view using `ViewConfigure`:

### 1. The `configure` Method

The simplest way to use `ViewConfigure` is with the `configure` method. This method takes arrays of `listeners`, `stores`, and `styles`.

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

### 2. The Builder Pattern

For more complex configurations, you can use the `ViewConfigurator` builder pattern.

```swift
import SwiftUI
import ViewConfigure

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .configured {
                $0.addStyle(PaddingStyle(length: 16))
                  .addStyle(BackgroundStyle(color: .blue, cornerRadius: 8))
                  .addStyle(ForegroundColorStyle(color: .white))
                  .addListener(TapListener { print("Tapped!") })
            }
    }
}
```

### 3. The Result Builder

You can also use a result builder for a more declarative syntax.

```swift
import SwiftUI
import ViewConfigure

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .configured {
                style(PaddingStyle(length: 16))
                style(BackgroundStyle(color: .blue, cornerRadius: 8))
                style(ForegroundColorStyle(color: .white))
                listener(TapListener { print("Tapped!") })
            }
    }
}
```

## Creating Custom Components

### Using the @Register Macro

`ViewConfigure` provides a powerful `@Register` macro that automatically registers your custom styles, listeners, and stores to their respective namespaces. This makes them easily accessible and discoverable.

#### Creating Custom Styles

```swift
import ViewConfigure

@Register(.style)
public struct CustomGradientStyle: Style {
    public typealias ModifiedContent = AnyView

    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint

    public init(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(
            content.background(
                LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
            )
        )
    }
}

// Usage: Now available as Styles.customGradientStyle
Text("Hello")
    .configure(styles: [AnyStyle(Styles.customGradientStyle)])
```

#### Creating Custom Listeners

```swift
import ViewConfigure

@Register(.listener)
public struct SwipeListener: Listener {
    public typealias ModifiedContent = AnyView

    let direction: SwipeDirection
    let action: () -> Void

    public init(direction: SwipeDirection, action: @escaping () -> Void) {
        self.direction = direction
        self.action = action
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(
            content.gesture(
                DragGesture()
                    .onEnded { value in
                        // Swipe detection logic here
                        if detectSwipe(value, direction: direction) {
                            action()
                        }
                    }
            )
        )
    }

    private func detectSwipe(_ value: DragGesture.Value, direction: SwipeDirection) -> Bool {
        // Implementation details...
        return true
    }
}

// Usage: Now available as Listeners.swipeListener
Text("Swipe me")
    .configure(listeners: [AnyListener(Listeners.swipeListener)])
```

#### Creating Custom Stores

```swift
import ViewConfigure
import Combine

@Register(.store)
public class UserPreferencesStore: Store {
    public let id = UUID()

    @Published public var theme: Theme = .light
    @Published public var fontSize: CGFloat = 16
    @Published public var notifications: Bool = true

    public required init() {}

    public func toggleTheme() {
        theme = theme == .light ? .dark : .light
    }
}

// Usage: Now available as Stores.userPreferencesStore
Text("Settings")
    .configure(stores: [AnyStore(Stores.userPreferencesStore)])
```

### Manual Registration (Alternative)

If you prefer not to use the macro, you can manually extend the respective namespaces:

```swift
extension Styles {
    static var customGradient: CustomGradientStyle {
        CustomGradientStyle(colors: [.blue, .purple])
    }
}

extension Listeners {
    static var customSwipe: SwipeListener {
        SwipeListener(direction: .left) { print("Swiped left!") }
    }
}

extension Stores {
    static var userPreferences: UserPreferencesStore {
        UserPreferencesStore()
    }
}
```

## Protocols

`ViewConfigure` is built around three core protocols:

- **`Listener`:** A protocol for event handlers that can be applied to views.
- **`Store`:** A protocol for `ObservableObject` stores that can be injected into the environment.
- **`Style`:** A protocol for visual modifiers that can be applied to views.

### Protocol Requirements

Each protocol has specific requirements:

#### Style Protocol

```swift
public protocol Style {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
```

#### Listener Protocol

```swift
public protocol Listener {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
```

#### Store Protocol

```swift
public protocol Store: ObservableObject {
    var id: UUID { get }
    init()
}
```

## Type-Erased Wrappers

To allow for heterogeneous arrays of listeners and styles, `ViewConfigure` provides the following type-erased wrappers:

- **`AnyListener`:** A type-erased wrapper for the `Listener` protocol.
- **`AnyStore`:** A type-erased wrapper for the `Store` protocol.
- **`AnyStyle`:** A type-erased wrapper for the `Style` protocol.

## Listeners

`ViewConfigure` comes with a number of built-in listeners:

- **`HoverListener`:** For hover events.
- **`TapListener`:** For tap gesture events.
- **`LongPressListener`:** For long press gesture events.
- **`AppearListener`:** For view appear and disappear events.
- **`ChangeListener`:** For value change events.
- **`FocusListener`:** For focus state changes.
- **`DragListener`:** For drag gesture events.

## Styles

`ViewConfigure` also comes with a number of built-in styles:

- **`PaddingStyle`:** For applying padding to views.
- **`BackgroundStyle`:** For applying a background to views.
- **`ShadowStyle`:** For applying a shadow to views.
- **`FrameStyle`:** For applying frame constraints to views.
- **`CornerRadiusStyle`:** For applying a corner radius to views.
- **`BorderStyle`:** For applying a border to views.
- **`OpacityStyle`:** For applying opacity to views.
- **`ForegroundColorStyle`:** For applying a foreground color to views.
- **`FontStyle`:** For applying a font to views.
- **`TitlebarStyle` (macOS):** For controlling titlebar visibility on macOS.
- **`ClipShapeStyle`:** For applying a clip shape to views.
- **`DisabledStyle`:** For disabling view interaction.

## Testing

This package comes with a suite of unit tests to ensure that all components are working as expected. You can run the tests in Xcode by selecting a simulator and pressing `Cmd + U`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
