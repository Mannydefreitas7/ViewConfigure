# Protocols

Understand the core protocols that power ViewConfigure's architecture.

## Overview

ViewConfigure is built around three fundamental protocols that define how components interact with SwiftUI views. These protocols provide a consistent interface for applying configurations while maintaining type safety and performance.

## Core Protocols

### Listener Protocol

The `Listener` protocol defines event handlers that can be applied to views to respond to user interactions or system events.

```swift
public protocol Listener {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
```

Listeners are responsible for:
- Handling user interactions (taps, gestures, hover events)
- Responding to system events (view appearance, focus changes)
- Triggering actions based on data changes

**Example Implementation:**

```swift
struct TapListener: Listener {
    let action: () -> Void
    
    func apply<Content: View>(to content: Content) -> some View {
        content.onTapGesture(perform: action)
    }
}
```

### Store Protocol

The `Store` protocol defines observable objects that can be injected into SwiftUI's environment system for state management.

```swift
public protocol Store: ObservableObject {
    var id: UUID { get }
    init()
}
```

Stores must:
- Conform to `ObservableObject` for SwiftUI reactivity
- Have a unique identifier for environment management
- Provide a parameterless initializer for automatic instantiation

**Example Implementation:**

```swift
class UserPreferencesStore: Store {
    let id = UUID()
    
    @Published var theme: Theme = .light
    @Published var fontSize: CGFloat = 16
    
    required init() {}
    
    func toggleTheme() {
        theme = theme == .light ? .dark : .light
    }
}
```

### Style Protocol

The `Style` protocol defines visual modifiers that can be applied to views to change their appearance.

```swift
public protocol Style {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
```

Styles handle:
- Visual appearance modifications (colors, fonts, backgrounds)
- Layout adjustments (padding, frames, alignment)
- Visual effects (shadows, opacity, clipping)

**Example Implementation:**

```swift
struct PaddingStyle: Style {
    let length: CGFloat
    
    func apply<Content: View>(to content: Content) -> some View {
        content.padding(length)
    }
}
```

## Protocol Design Principles

### Type Safety

All protocols use associated types to maintain compile-time type safety:

```swift
// The return type is known at compile time
func apply<Content: View>(to content: Content) -> ModifiedContent
```

This ensures that:
- Invalid configurations are caught at compile time
- Performance optimizations can be applied by the compiler
- Auto-completion works correctly in Xcode

### Composability

Protocols are designed to work together seamlessly:

```swift
Text("Hello")
    .configured {
        style(PaddingStyle(length: 16))      // Style protocol
        listener(TapListener { print("Hi") }) // Listener protocol
        store(UserPreferencesStore())         // Store protocol
    }
```

### Flexibility

Each protocol allows for different return types through associated types:

```swift
// Can return any View type
struct SimpleStyle: Style {
    func apply<Content: View>(to content: Content) -> some View {
        content.foregroundColor(.blue)
    }
}

// Can return AnyView for complex modifications
struct ComplexStyle: Style {
    func apply<Content: View>(to content: Content) -> AnyView {
        AnyView(
            VStack {
                content
                Text("Additional content")
            }
        )
    }
}
```

## Implementation Guidelines

### For Listeners

When implementing custom listeners:

1. **Keep it focused**: Each listener should handle one type of event
2. **Use closures for actions**: Allow users to provide custom behavior
3. **Consider performance**: Avoid heavy computations in gesture handlers
4. **Handle edge cases**: Consider what happens when gestures conflict

```swift
struct CustomGestureListener: Listener {
    let minimumDistance: CGFloat
    let action: (DragGesture.Value) -> Void
    
    func apply<Content: View>(to content: Content) -> some View {
        content.gesture(
            DragGesture(minimumDistance: minimumDistance)
                .onEnded(action)
        )
    }
}
```

### For Stores

When implementing custom stores:

1. **Use @Published**: Mark observable properties with `@Published`
2. **Keep it cohesive**: Group related state together
3. **Provide methods**: Include methods to modify state safely
4. **Consider persistence**: Think about whether state should persist across app launches

```swift
class ShoppingCartStore: Store {
    let id = UUID()
    
    @Published var items: [CartItem] = []
    @Published var total: Decimal = 0
    
    required init() {}
    
    func addItem(_ item: CartItem) {
        items.append(item)
        updateTotal()
    }
    
    private func updateTotal() {
        total = items.reduce(0) { $0 + $1.price }
    }
}
```

### For Styles

When implementing custom styles:

1. **Be composable**: Don't interfere with other styles
2. **Use view modifiers**: Leverage SwiftUI's built-in modifiers when possible
3. **Consider platform differences**: Handle platform-specific styling gracefully
4. **Provide sensible defaults**: Make common use cases simple

```swift
struct GradientBackgroundStyle: Style {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(
        colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.background(
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }
}
```

## See Also

- <doc:TypeErasedWrappers>
- <doc:CreatingCustomComponents>
- <doc:RegisterMacro>
