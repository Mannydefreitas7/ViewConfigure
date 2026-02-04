# Listeners

Handle user interactions and system events with built-in listener components.

## Overview

Listeners in ViewConfigure provide a way to handle various user interactions and system events in a declarative manner. Each listener conforms to the ``Listener`` protocol and can be applied to any SwiftUI view through the configuration system.

Listeners are designed to be:
- **Composable**: Multiple listeners can be applied to the same view
- **Reusable**: Create once, use anywhere in your application
- **Type-safe**: Compile-time guarantees for correct usage
- **Performance-focused**: Minimal overhead when applied to views

## Built-in Listeners

### Gesture Listeners

#### TapListener

Handles tap gestures on views with customizable tap count.

```swift
Text("Tap me!")
    .configured {
        listener(TapListener { 
            print("View was tapped!") 
        })
    }

// Multi-tap support
Button("Double tap") { }
    .configured {
        listener(TapListener(count: 2) {
            print("Double tapped!")
        })
    }
```

**Parameters:**
- `count`: Number of taps required (default: 1)
- `onTap`: Closure to execute when gesture is recognized

#### LongPressListener

Responds to long press gestures with configurable duration.

```swift
Image("photo")
    .configured {
        listener(LongPressListener(minimumDuration: 1.0) {
            print("Long press detected!")
        })
    }
```

**Parameters:**
- `minimumDuration`: Minimum press duration in seconds (default: 0.5)
- `onPress`: Closure to execute when gesture is recognized

#### DragListener

Handles drag gestures with support for both changed and ended events.

```swift
Rectangle()
    .configured {
        listener(DragListener(
            onChanged: { value in
                print("Dragging: \(value.translation)")
            },
            onEnded: { value in
                print("Drag ended at: \(value.location)")
            }
        ))
    }
```

**Parameters:**
- `onChanged`: Closure called during drag movement
- `onEnded`: Optional closure called when drag ends

### Interaction Listeners

#### HoverListener

Responds to mouse hover events (macOS, iPadOS with pointer support).

```swift
Card()
    .configured {
        listener(HoverListener { isHovering in
            print("Hover state: \(isHovering)")
        })
    }
```

**Parameters:**
- `onHover`: Closure called with hover state (true when entering, false when exiting)

### Lifecycle Listeners

#### AppearListener

Handles view appearance and disappearance events.

```swift
ContentView()
    .configured {
        listener(AppearListener(
            onAppear: { 
                print("View appeared") 
            },
            onDisappear: { 
                print("View disappeared") 
            }
        ))
    }
```

**Parameters:**
- `onAppear`: Optional closure called when view appears
- `onDisappear`: Optional closure called when view disappears

### State Change Listeners

#### ChangeListener

Monitors changes to any equatable value.

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .configured {
                listener(ChangeListener(value: count) { newValue in
                    print("Count changed to: \(newValue)")
                })
            }
    }
}
```

**Parameters:**
- `value`: The value to monitor for changes
- `onChange`: Closure called with the new value when it changes

#### FocusListener

Tracks focus state changes for interactive elements.

```swift
struct LoginForm: View {
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        TextField("Email", text: .constant(""))
            .configured {
                listener(FocusListener(
                    isFocused: isEmailFocused
                ) { focused in
                    print("Email field focus: \(focused)")
                })
            }
    }
}
```

**Parameters:**
- `isFocused`: The focus state to monitor
- `onFocusChange`: Closure called when focus state changes

## Usage Patterns

### Combining Multiple Listeners

You can apply multiple listeners to the same view:

```swift
Button("Interactive Button") { }
    .configured {
        listener(TapListener { print("Tapped") })
        listener(HoverListener { print("Hover: \($0)") })
        listener(LongPressListener { print("Long pressed") })
    }
```

### Conditional Listeners

Apply listeners based on conditions:

```swift
Text("Content")
    .configured {
        if enableInteraction {
            listener(TapListener { handleTap() })
        }
        if trackHover {
            listener(HoverListener { updateHoverState($0) })
        }
    }
```

### Listener State Management

Use listeners to update application state:

```swift
struct InteractiveView: View {
    @State private var tapCount = 0
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            Text("Taps: \(tapCount)")
            Text("Hovering: \(isHovering)")
        }
        .configured {
            listener(TapListener { 
                tapCount += 1 
            })
            listener(HoverListener { hovering in
                isHovering = hovering
            })
        }
    }
}
```

## Best Practices

### Performance Considerations

- **Minimize closure captures**: Avoid capturing heavy objects unnecessarily
- **Use weak references**: When capturing `self`, consider using `[weak self]`
- **Batch updates**: Group related state changes together

```swift
// Good: Minimal captures
listener(TapListener { 
    updateCounter() 
})

// Better: Weak self reference when needed
listener(TapListener { [weak self] in
    self?.updateCounter()
})
```

### Event Handling

- **Keep handlers focused**: Each listener should handle one specific interaction
- **Provide feedback**: Give users immediate feedback for their actions
- **Handle edge cases**: Consider what happens when multiple gestures occur

```swift
// Good: Focused responsibility
listener(TapListener { 
    hapticFeedback.impactOccurred()
    analyticsService.track("button_tapped")
    navigateToNextScreen()
})
```

### Accessibility

Consider accessibility when using listeners:

```swift
Text("Important Action")
    .configured {
        listener(TapListener { performAction() })
        // Also support accessibility actions
        style(AccessibilityStyle(
            action: .default,
            handler: { performAction() }
        ))
    }
```

## See Also

- ``Listener``
- ``AnyListener``
- <doc:CreatingCustomComponents>
- <doc:Styles>
