# Register Macro

Automatically register custom components in their respective namespaces with the `@Register` macro.

## Overview

The `@Register` macro provides a convenient way to automatically register your custom listeners, stores, and styles in their respective namespaces (`Listeners`, `Stores`, and `Styles`). This makes your custom components easily discoverable and accessible throughout your application.

Without the macro, you would need to manually extend the appropriate namespace for each custom component. The `@Register` macro automates this process, reducing boilerplate code and ensuring consistent registration patterns.

## Basic Usage

### Registering Styles

Use `@Register(.style)` to automatically add your custom style to the `Styles` namespace:

```swift
@Register(.style)
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

// Usage: Now available as Styles.gradientBackgroundStyle
Text("Gradient text")
    .configured {
        style(Styles.gradientBackgroundStyle)
    }
```

### Registering Listeners

Use `@Register(.listener)` to add your custom listener to the `Listeners` namespace:

```swift
@Register(.listener)
struct RotationGestureListener: Listener {
    let onRotate: (Angle) -> Void
    let onEnd: ((Angle) -> Void)?
    
    init(
        onRotate: @escaping (Angle) -> Void,
        onEnd: ((Angle) -> Void)? = nil
    ) {
        self.onRotate = onRotate
        self.onEnd = onEnd
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.gesture(
            RotationGesture()
                .onChanged { angle in
                    onRotate(angle)
                }
                .onEnded { angle in
                    onEnd?(angle)
                }
        )
    }
}

// Usage: Now available as Listeners.rotationGestureListener
Image("wheel")
    .configured {
        listener(Listeners.rotationGestureListener)
    }
```

### Registering Stores

Use `@Register(.store)` to add your custom store to the `Stores` namespace:

```swift
@Register(.store)
class MediaPlayerStore: Store {
    let id = UUID()
    
    @Published var currentTrack: Track?
    @Published var isPlaying: Bool = false
    @Published var volume: Double = 0.5
    @Published var playbackPosition: TimeInterval = 0
    
    required init() {}
    
    func play() {
        isPlaying = true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func setVolume(_ volume: Double) {
        self.volume = max(0, min(1, volume))
    }
    
    func seek(to position: TimeInterval) {
        playbackPosition = position
    }
}

// Usage: Now available as Stores.mediaPlayerStore
PlayerView()
    .configured {
        store(Stores.mediaPlayerStore)
    }
```

## Naming Conventions

The `@Register` macro automatically generates accessor names based on your type name:

### Style Naming

- `ButtonStyle` → `Styles.buttonStyle`
- `CustomGradientStyle` → `Styles.customGradientStyle`
- `NeonGlowStyle` → `Styles.neonGlowStyle`

### Listener Naming

- `SwipeListener` → `Listeners.swipeListener`  
- `DoubleClickListener` → `Listeners.doubleClickListener`
- `KeyboardShortcutListener` → `Listeners.keyboardShortcutListener`

### Store Naming

- `UserStore` → `Stores.userStore`
- `ShoppingCartStore` → `Stores.shoppingCartStore`
- `GameStateStore` → `Stores.gameStateStore`

The macro converts PascalCase type names to camelCase accessor names, removing common suffixes like "Style", "Listener", and "Store".

## Advanced Usage

### Parameterized Registration

Create factory methods for components that need configuration:

```swift
@Register(.style)
struct CardStyle: Style {
    let cornerRadius: CGFloat
    let shadowOpacity: Double
    let backgroundColor: Color
    
    init(
        cornerRadius: CGFloat = 12,
        shadowOpacity: Double = 0.2,
        backgroundColor: Color = .white
    ) {
        self.cornerRadius = cornerRadius
        self.shadowOpacity = shadowOpacity
        self.backgroundColor = backgroundColor
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(shadowOpacity), radius: 4)
    }
}

// The macro generates the basic accessor
// You can extend with factory methods:
extension Styles {
    static func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowOpacity: Double = 0.2,
        backgroundColor: Color = .white
    ) -> CardStyle {
        CardStyle(
            cornerRadius: cornerRadius,
            shadowOpacity: shadowOpacity,
            backgroundColor: backgroundColor
        )
    }
}

// Usage with parameters
VStack {
    Text("Content")
}
.configured {
    style(Styles.cardStyle(cornerRadius: 16, backgroundColor: .blue))
}
```

### Conditional Registration

Register components conditionally based on platform or feature flags:

```swift
#if os(macOS)
@Register(.listener)
struct RightClickListener: Listener {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.onReceive(rightClickPublisher) { _ in
            action()
        }
    }
    
    private var rightClickPublisher: AnyPublisher<Void, Never> {
        // Right-click detection implementation
        NotificationCenter.default
            .publisher(for: .rightMouseDown)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
#endif

// Usage (only available on macOS)
#if os(macOS)
Text("Right-clickable")
    .configured {
        listener(Listeners.rightClickListener)
    }
#endif
```

## Integration with Manual Registration

You can combine macro registration with manual extensions:

```swift
@Register(.style)
struct BaseCardStyle: Style {
    // Basic card implementation
}

// Manual extension for additional variants
extension Styles {
    static var primaryCard: BaseCardStyle {
        BaseCardStyle(backgroundColor: .blue, textColor: .white)
    }
    
    static var secondaryCard: BaseCardStyle {
        BaseCardStyle(backgroundColor: .gray, textColor: .primary)
    }
    
    static var dangerCard: BaseCardStyle {
        BaseCardStyle(backgroundColor: .red, textColor: .white)
    }
}
```

## Benefits of Using @Register

### Discoverability

Components registered with `@Register` appear in Xcode's autocomplete, making them easy to discover:

```swift
Text("Example")
    .configured {
        style(Styles.| // Autocomplete shows all registered styles
    }
```

### Consistency

The macro ensures consistent naming patterns across your codebase:

- All styles accessed through `Styles.`
- All listeners accessed through `Listeners.`
- All stores accessed through `Stores.`

### Reduced Boilerplate

Without `@Register`, you would need to manually extend each namespace:

```swift
// Without @Register - manual extension required
struct CustomStyle: Style {
    // Implementation
}

extension Styles {
    static var customStyle: CustomStyle {
        CustomStyle()
    }
}

// With @Register - automatic registration
@Register(.style)
struct CustomStyle: Style {
    // Implementation
}
```

## Limitations and Considerations

### Macro Expansion

The `@Register` macro expands to create extensions at compile time. You can view the expanded code using Xcode's macro expansion feature to understand what's generated.

### Generic Types

The macro works best with concrete types. For generic components, consider manual registration or factory methods:

```swift
// Generic type - manual registration recommended
struct GenericPaddingStyle<T: Numeric>: Style {
    let padding: T
    // Implementation
}

extension Styles {
    static func genericPadding<T: Numeric>(_ padding: T) -> GenericPaddingStyle<T> {
        GenericPaddingStyle(padding: padding)
    }
}
```

### Build-Time Generation

Since the macro generates code at build time, registered components are only available after compilation. This means:

- Clean builds are required when adding new `@Register` components
- Generated accessors won't appear in autocomplete until after the first build

## Best Practices

### Naming Components

Use descriptive names that clearly indicate the component's purpose:

```swift
@Register(.style)
struct AnimatedButtonHighlightStyle: Style {
    // Clear, descriptive name
}

@Register(.listener)  
struct DoubleTapGestureListener: Listener {
    // Indicates both gesture type and interaction count
}

@Register(.store)
class UserAuthenticationStore: Store {
    // Clearly indicates the domain and responsibility
}
```

### Documentation

Document registered components thoroughly:

```swift
@Register(.style)
/// Applies a glass morphism effect with configurable blur and opacity.
/// 
/// This style creates a modern glass-like appearance using background materials
/// and blur effects. It's particularly effective over colorful backgrounds.
///
/// - Parameters:
///   - material: The visual effect material to use for the background
///   - opacity: The opacity of the glass effect (0.0 to 1.0)
struct GlassmorphismStyle: Style {
    let material: Material
    let opacity: Double
    
    // Implementation
}
```

### Organization

Group related components together and use consistent file organization:

```
Sources/
  ViewConfigure/
    Styles/
      ButtonStyles.swift      // @Register(.style) button-related styles
      CardStyles.swift        // @Register(.style) card-related styles  
      EffectStyles.swift      // @Register(.style) visual effects
    Listeners/
      GestureListeners.swift  // @Register(.listener) gesture handlers
      EventListeners.swift    // @Register(.listener) system events
    Stores/
      AuthStores.swift        // @Register(.store) authentication stores
      DataStores.swift        // @Register(.store) data management stores
```

## See Also

- <doc:CreatingCustomComponents>
- <doc:Protocols>
- <doc:BestPractices>
