# Type-Erased Wrappers

Enable heterogeneous collections of listeners, stores, and styles with type-erased wrapper types.

## Overview

ViewConfigure provides type-erased wrappers that allow you to store different implementations of the same protocol in homogeneous collections. This is essential for the framework's flexibility, enabling you to apply multiple listeners, stores, or styles of different types to the same view.

Without type erasure, you would be limited to using only one type of listener, store, or style at a time due to Swift's strong typing system. The type-erased wrappers solve this problem by providing a common interface while preserving the underlying functionality.

## Why Type Erasure?

Swift's type system prevents mixing different concrete types in the same collection, even if they conform to the same protocol with associated types:

```swift
// This won't compile:
let styles = [
    PaddingStyle(length: 16),        // Different concrete types
    BackgroundStyle(color: .blue),   // Can't be in same array
    FontStyle(font: .headline)       // Without type erasure
]
```

Type-erased wrappers enable this flexibility:

```swift
// This works with type erasure:
let styles = [
    AnyStyle(PaddingStyle(length: 16)),
    AnyStyle(BackgroundStyle(color: .blue)),
    AnyStyle(FontStyle(font: .headline))
]
```

## AnyListener

The `AnyListener` wrapper enables heterogeneous collections of listener types.

### Structure

```swift
public struct AnyListener {
    public init<L: Listener>(_ listener: L)
    public func apply(to content: some View) -> AnyView
}
```

### Usage

```swift
let listeners = [
    AnyListener(TapListener { print("Tapped") }),
    AnyListener(HoverListener { print("Hover: \($0)") }),
    AnyListener(LongPressListener { print("Long pressed") })
]

Text("Interactive")
    .configure(listeners: listeners, stores: [], styles: [])
```

### Creating Custom Collections

```swift
extension Array where Element == AnyListener {
    static var interactionListeners: [AnyListener] {
        [
            AnyListener(TapListener { 
                HapticFeedback.impact()
            }),
            AnyListener(HoverListener { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            })
        ]
    }
    
    static var trackingListeners: [AnyListener] {
        [
            AnyListener(AppearListener(
                onAppear: { Analytics.trackViewAppeared() }
            )),
            AnyListener(ChangeListener(value: someTrackedValue) { newValue in
                Analytics.trackValueChanged(newValue)
            })
        ]
    }
}

// Usage
Button("Track me") { }
    .configure(listeners: .interactionListeners + .trackingListeners)
```

## AnyStore

The `AnyStore` wrapper enables heterogeneous collections of store types while preserving observation capabilities.

### Structure

```swift
@Observable
public class AnyStore {
    public let id: UUID
    public let objectWillChange: AnyPublisher<Void, Never>
    
    public init<S: Store>(_ store: S)
}
```

### Key Features

- **Preserves observation**: Maintains reactivity through `objectWillChange` publisher
- **Unique identification**: Each wrapper preserves the original store's ID
- **Environment integration**: Works seamlessly with SwiftUI's environment system

### Usage

```swift
let stores = [
    AnyStore(UserStore()),
    AnyStore(ThemeStore()),
    AnyStore(CartStore()),
    AnyStore(AnalyticsStore())
]

RootView()
    .configure(listeners: [], stores: stores, styles: [])
```

### Conditional Store Injection

```swift
struct ConditionalStoreView: View {
    let isUserLoggedIn: Bool
    
    var body: some View {
        ContentView()
            .configured {
                // Always include core stores
                store(AnyStore(ThemeStore()))
                store(AnyStore(AppStateStore()))
                
                // Conditionally include user-specific stores
                if isUserLoggedIn {
                    store(AnyStore(UserPreferencesStore()))
                    store(AnyStore(ShoppingCartStore()))
                }
            }
    }
}
```

## AnyStyle

The `AnyStyle` wrapper enables heterogeneous collections of style types.

### Structure

```swift
public struct AnyStyle {
    public init<S: Style>(_ style: S)
    public func apply(to content: some View) -> AnyView
}
```

### Usage

```swift
let cardStyles = [
    AnyStyle(PaddingStyle(length: 16)),
    AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12)),
    AnyStyle(ShadowStyle(color: .gray.opacity(0.3), radius: 4))
]

VStack {
    Text("Card content")
}
.configure(listeners: [], stores: [], styles: cardStyles)
```

### Style Composition Patterns

```swift
extension Array where Element == AnyStyle {
    static func button(
        color: Color = .blue,
        size: ButtonSize = .medium
    ) -> [AnyStyle] {
        var styles = [
            AnyStyle(BackgroundStyle(color: color, cornerRadius: 8)),
            AnyStyle(ForegroundColorStyle(color: .white)),
            AnyStyle(FontStyle(font: .body.bold()))
        ]
        
        switch size {
        case .small:
            styles.append(AnyStyle(PaddingStyle(horizontal: 12, vertical: 6)))
        case .medium:
            styles.append(AnyStyle(PaddingStyle(horizontal: 16, vertical: 10)))
        case .large:
            styles.append(AnyStyle(PaddingStyle(horizontal: 24, vertical: 14)))
        }
        
        return styles
    }
    
    static var card: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 20)),
            AnyStyle(BackgroundStyle(color: .white, cornerRadius: 16)),
            AnyStyle(ShadowStyle(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            ))
        ]
    }
}
```

## Performance Considerations

### Memory Usage

Type-erased wrappers add a small memory overhead by storing closures that capture the original implementations:

```swift
// AnyStyle stores a closure that captures the original style
private let _apply: (AnyView) -> AnyView
```

### Runtime Performance

- **Minimal overhead**: The wrapper simply forwards calls to the original implementation
- **No dynamic dispatch**: The closure captures the concrete type at initialization
- **View identity**: All wrappers return `AnyView`, which may affect view identity optimizations

### Best Practices

- **Reuse collections**: Create static collections rather than recreating wrappers frequently
- **Consider alternatives**: For single-type collections, use the concrete types directly

```swift
// Good: Reusable collections
extension Array where Element == AnyStyle {
    static let primaryCard = [
        AnyStyle(PaddingStyle(length: 16)),
        AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8))
    ]
}

// Good: Direct usage for single types
Text("Simple")
    .configured {
        style(PaddingStyle(length: 16))
    }

// Less optimal: Unnecessary wrapping
Text("Simple")
    .configure(styles: [AnyStyle(PaddingStyle(length: 16))])
```

## Advanced Usage

### Dynamic Collections

Build collections at runtime based on conditions:

```swift
func buildStyles(for state: ViewState) -> [AnyStyle] {
    var styles: [AnyStyle] = [
        AnyStyle(PaddingStyle(length: 16))
    ]
    
    switch state {
    case .normal:
        styles.append(AnyStyle(BackgroundStyle(color: .white)))
    case .highlighted:
        styles.append(AnyStyle(BackgroundStyle(color: .blue)))
        styles.append(AnyStyle(ForegroundColorStyle(color: .white)))
    case .disabled:
        styles.append(AnyStyle(BackgroundStyle(color: .gray)))
        styles.append(AnyStyle(OpacityStyle(opacity: 0.6)))
    }
    
    return styles
}
```

### Conditional Wrapper Creation

```swift
func createConfigurationComponents(
    enableInteraction: Bool,
    enableAnalytics: Bool
) -> (listeners: [AnyListener], stores: [AnyStore], styles: [AnyStyle]) {
    
    var listeners: [AnyListener] = []
    var stores: [AnyStore] = [AnyStore(ThemeStore())]
    var styles: [AnyStyle] = [AnyStyle(PaddingStyle(length: 16))]
    
    if enableInteraction {
        listeners.append(AnyListener(TapListener { handleTap() }))
        listeners.append(AnyListener(HoverListener { handleHover($0) }))
    }
    
    if enableAnalytics {
        stores.append(AnyStore(AnalyticsStore()))
        listeners.append(AnyListener(AppearListener(
            onAppear: { trackViewAppearance() }
        )))
    }
    
    return (listeners, stores, styles)
}
```

## Integration with Result Builders

Type-erased wrappers work seamlessly with ViewConfigure's result builder syntax:

```swift
Text("Configured")
    .configured {
        // Automatically wrapped in type-erased wrappers
        style(PaddingStyle(length: 16))
        style(BackgroundStyle(color: .blue))
        listener(TapListener { print("Tapped") })
        store(UserStore())
    }
```

The result builder automatically wraps each component in the appropriate type-erased wrapper, providing a clean API while maintaining type safety and flexibility.

## See Also

- ``AnyListener``
- ``AnyStore`` 
- ``AnyStyle``
- <doc:Protocols>
- <doc:ResultBuilder>
