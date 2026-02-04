# Styles

Apply visual modifications to your SwiftUI views with built-in style components.

## Overview

Styles in ViewConfigure provide a declarative way to apply visual modifications to SwiftUI views. Each style conforms to the ``Style`` protocol and encapsulates a specific visual transformation that can be applied to any view.

Styles are designed to be:
- **Composable**: Multiple styles can be applied to the same view
- **Reusable**: Create once, use throughout your application
- **Chainable**: Apply styles in any order for cumulative effects
- **Performance-optimized**: Minimal runtime overhead

## Layout Styles

### PaddingStyle

Adds padding around views with flexible edge and length configuration.

```swift
Text("Padded content")
    .configured {
        style(PaddingStyle(length: 16))
    }

// Specific edges
VStack {
    Text("Content")
}
.configured {
    style(PaddingStyle(edges: [.leading, .trailing], length: 20))
}
```

**Parameters:**
- `edges`: Edge set to apply padding (default: `.all`)
- `length`: Padding amount in points (optional, uses system default if nil)

### FrameStyle

Sets explicit frame dimensions with alignment control.

```swift
Rectangle()
    .configured {
        style(FrameStyle(width: 200, height: 100))
    }

// With custom alignment
Image("icon")
    .configured {
        style(FrameStyle(
            width: 50,
            height: 50,
            alignment: .topLeading
        ))
    }
```

**Parameters:**
- `width`: Fixed width in points (optional)
- `height`: Fixed height in points (optional)
- `alignment`: Content alignment within frame (default: `.center`)

## Visual Appearance Styles

### BackgroundStyle

Applies background colors with optional corner radius.

```swift
Text("With background")
    .configured {
        style(BackgroundStyle(color: .blue))
    }

// With rounded corners
Button("Rounded button") { }
    .configured {
        style(BackgroundStyle(color: .green, cornerRadius: 8))
    }
```

**Parameters:**
- `color`: Background color
- `cornerRadius`: Optional corner radius in points

### ForegroundColorStyle

Sets the foreground color for text and symbols.

```swift
VStack {
    Text("Primary text")
    Image(systemName: "star")
}
.configured {
    style(ForegroundColorStyle(color: .primary))
}
```

**Parameters:**
- `color`: Foreground color to apply

### ShadowStyle

Adds drop shadows with customizable appearance.

```swift
Card()
    .configured {
        style(ShadowStyle(
            color: .black.opacity(0.2),
            radius: 5,
            x: 0,
            y: 2
        ))
    }

// Quick shadow with defaults
Text("Shadowed")
    .configured {
        style(ShadowStyle())
    }
```

**Parameters:**
- `color`: Shadow color (default: black with 20% opacity)
- `radius`: Blur radius (default: 5)
- `x`: Horizontal offset (default: 0)
- `y`: Vertical offset (default: 2)

## Shape and Border Styles

### CornerRadiusStyle

Applies corner radius to views.

```swift
Rectangle()
    .configured {
        style(CornerRadiusStyle(radius: 12))
    }
```

**Parameters:**
- `radius`: Corner radius in points

### BorderStyle

Adds borders around views.

```swift
Text("Bordered")
    .configured {
        style(BorderStyle(color: .gray, width: 2))
    }
```

**Parameters:**
- `color`: Border color
- `width`: Border width in points (default: 1)

### ClipShapeStyle

Clips content to a specific shape.

```swift
Image("photo")
    .configured {
        style(ClipShapeStyle(shape: Circle()))
    }

// Custom shape
Rectangle()
    .configured {
        style(ClipShapeStyle(shape: RoundedRectangle(cornerRadius: 16)))
    }
```

**Parameters:**
- `shape`: Shape to clip to (any type conforming to `Shape`)

## Typography Styles

### FontStyle

Applies font styling to text elements.

```swift
Text("Styled text")
    .configured {
        style(FontStyle(font: .title.bold()))
    }

// System fonts
Text("Body text")
    .configured {
        style(FontStyle(font: .body))
    }

// Custom fonts
Text("Custom font")
    .configured {
        style(FontStyle(font: .custom("Helvetica", size: 18)))
    }
```

**Parameters:**
- `font`: Font to apply (any SwiftUI `Font`)

## Interactive Styles

### OpacityStyle

Controls view transparency.

```swift
Button("Disabled") { }
    .configured {
        style(OpacityStyle(opacity: 0.6))
    }
```

**Parameters:**
- `opacity`: Opacity value from 0.0 to 1.0

### DisabledStyle

Controls interaction capability.

```swift
Button("Submit") { }
    .configured {
        style(DisabledStyle(isDisabled: !formIsValid))
    }
```

**Parameters:**
- `isDisabled`: Whether the view should be disabled

## Platform-Specific Styles

### TitlebarStyle (macOS)

Controls window titlebar visibility on macOS.

```swift
#if os(macOS)
WindowGroup {
    ContentView()
        .configured {
            style(TitlebarStyle(hidden: true))
        }
}
#endif
```

**Parameters:**
- `hidden`: Whether to hide the titlebar (default: false)

**Availability:** macOS 13.0+

## Style Composition

### Combining Styles

Apply multiple styles for rich visual effects:

```swift
Text("Styled card")
    .configured {
        style(PaddingStyle(length: 20))
        style(BackgroundStyle(color: .blue, cornerRadius: 12))
        style(ForegroundColorStyle(color: .white))
        style(ShadowStyle(color: .blue.opacity(0.3), radius: 8))
        style(FontStyle(font: .headline.bold()))
    }
```

### Order Considerations

Style order can affect the final appearance:

```swift
// Background first, then padding
Text("Example")
    .configured {
        style(BackgroundStyle(color: .blue))
        style(PaddingStyle(length: 16))  // Padding outside background
    }

// Padding first, then background
Text("Example")
    .configured {
        style(PaddingStyle(length: 16))
        style(BackgroundStyle(color: .blue))  // Background includes padding
    }
```

## Usage Patterns

### Conditional Styling

Apply styles based on state:

```swift
struct ConditionalCard: View {
    let isSelected: Bool
    
    var body: some View {
        Text("Card content")
            .configured {
                style(PaddingStyle(length: 16))
                style(BackgroundStyle(
                    color: isSelected ? .blue : .gray.opacity(0.2)
                ))
                if isSelected {
                    style(BorderStyle(color: .blue, width: 2))
                }
            }
    }
}
```

### Reusable Style Groups

Create collections of related styles:

```swift
extension Array where Element == AnyStyle {
    static var primaryButton: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(horizontal: 24, vertical: 12)),
            AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8)),
            AnyStyle(ForegroundColorStyle(color: .white)),
            AnyStyle(FontStyle(font: .body.bold()))
        ]
    }
    
    static var card: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 16)),
            AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12)),
            AnyStyle(ShadowStyle(
                color: .black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2
            ))
        ]
    }
}

// Usage
Button("Submit") { }
    .configure(styles: .primaryButton)

VStack {
    Text("Card content")
}
.configure(styles: .card)
```

### Responsive Styling

Adapt styles to different contexts:

```swift
struct ResponsiveText: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        Text("Responsive content")
            .configured {
                style(PaddingStyle(
                    length: sizeClass == .compact ? 12 : 24
                ))
                style(FontStyle(
                    font: sizeClass == .compact ? .body : .title
                ))
            }
    }
}
```

## Best Practices

### Performance

- **Minimize dynamic changes**: Avoid creating new style instances in body computations
- **Use static collections**: Pre-define common style combinations
- **Consider order**: Apply expensive operations (like shadows) last

```swift
// Good: Static style definitions
extension Array where Element == AnyStyle {
    static let cardStyles = [
        AnyStyle(PaddingStyle(length: 16)),
        AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12))
    ]
}

// Better: Reuse predefined collections
Text("Content")
    .configure(styles: .cardStyles)
```

### Design Consistency

- **Use design tokens**: Define colors, spacing, and typography systematically
- **Create style libraries**: Group related styles for consistent application
- **Document conventions**: Make style usage patterns clear to your team

```swift
struct DesignTokens {
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let surface = Color.white
    }
}
```

### Accessibility

Consider accessibility when applying styles:

```swift
Text("Important message")
    .configured {
        style(FontStyle(font: .body))  // Respects Dynamic Type
        style(ForegroundColorStyle(color: .primary))  // High contrast
        // Avoid purely color-based information
    }
```

## See Also

- ``Style``
- ``AnyStyle``
- <doc:CreatingCustomComponents>
- <doc:Listeners>
