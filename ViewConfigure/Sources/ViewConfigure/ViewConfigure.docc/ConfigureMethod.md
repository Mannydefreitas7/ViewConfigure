# Configure Method

Use the direct `configure` method to apply listeners, stores, and styles to your SwiftUI views.

## Overview

The `configure` method is the most straightforward way to apply ViewConfigure components to your SwiftUI views. It accepts three optional arrays containing listeners, stores, and styles, and applies them all in a single method call.

This method is ideal when you:
- Have a specific set of components to apply
- Want explicit control over what gets configured
- Need to conditionally apply configurations
- Prefer a more imperative style

## Method Signature

```swift
func configure(
    listeners: [AnyListener] = [],
    stores: [AnyStore] = [],
    styles: [AnyStyle] = []
) -> some View
```

### Parameters

- **listeners**: An array of `AnyListener` objects that handle user interactions and system events
- **stores**: An array of `AnyStore` objects that provide observable state management
- **styles**: An array of `AnyStyle` objects that apply visual modifications

All parameters have default empty arrays, so you only need to specify the components you want to use.

## Basic Usage

### Single Component Types

Apply only the components you need:

```swift
// Only styles
Text("Styled text")
    .configure(styles: [
        AnyStyle(PaddingStyle(length: 16)),
        AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8)),
        AnyStyle(ForegroundColorStyle(color: .white))
    ])

// Only listeners
Button("Interactive") { }
    .configure(listeners: [
        AnyListener(TapListener { print("Tapped!") }),
        AnyListener(HoverListener { print("Hover: \($0)") })
    ])

// Only stores
ContentView()
    .configure(stores: [
        AnyStore(UserStore()),
        AnyStore(ThemeStore())
    ])
```

### Combined Components

Apply multiple component types together:

```swift
struct InteractiveCard: View {
    var body: some View {
        VStack {
            Text("Interactive Card")
            Text("Tap me!")
        }
        .configure(
            listeners: [
                AnyListener(TapListener { 
                    print("Card tapped") 
                }),
                AnyListener(HoverListener { hovering in
                    print("Hovering: \(hovering)")
                })
            ],
            stores: [
                AnyStore(AnalyticsStore())
            ],
            styles: [
                AnyStyle(PaddingStyle(length: 20)),
                AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12)),
                AnyStyle(ShadowStyle(color: .gray.opacity(0.3), radius: 4)),
                AnyStyle(BorderStyle(color: .blue.opacity(0.3), width: 1))
            ]
        )
    }
}
```

## Advanced Usage

### Conditional Configuration

Apply components based on state or conditions:

```swift
struct ConditionalView: View {
    let isInteractive: Bool
    let showShadow: Bool
    
    var body: some View {
        Text("Conditional styling")
            .configure(
                listeners: isInteractive ? [
                    AnyListener(TapListener { handleTap() }),
                    AnyListener(LongPressListener { handleLongPress() })
                ] : [],
                styles: [
                    AnyStyle(PaddingStyle(length: 16)),
                    AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8))
                ] + (showShadow ? [
                    AnyStyle(ShadowStyle(radius: 4))
                ] : [])
            )
    }
}
```

### Dynamic Component Building

Build component arrays dynamically:

```swift
struct DynamicConfigurationView: View {
    let config: ViewConfiguration
    
    var body: some View {
        Text("Dynamic config")
            .configure(
                listeners: buildListeners(),
                stores: buildStores(),
                styles: buildStyles()
            )
    }
    
    private func buildListeners() -> [AnyListener] {
        var listeners: [AnyListener] = []
        
        if config.enableTap {
            listeners.append(AnyListener(TapListener { handleTap() }))
        }
        
        if config.enableHover {
            listeners.append(AnyListener(HoverListener { handleHover($0) }))
        }
        
        if config.trackEvents {
            listeners.append(AnyListener(AppearListener(
                onAppear: { trackViewAppearance() }
            )))
        }
        
        return listeners
    }
    
    private func buildStores() -> [AnyStore] {
        var stores: [AnyStore] = []
        
        if config.needsUserData {
            stores.append(AnyStore(UserStore()))
        }
        
        if config.needsAnalytics {
            stores.append(AnyStore(AnalyticsStore()))
        }
        
        return stores
    }
    
    private func buildStyles() -> [AnyStyle] {
        var styles: [AnyStyle] = [
            AnyStyle(PaddingStyle(length: config.padding))
        ]
        
        if let backgroundColor = config.backgroundColor {
            styles.append(AnyStyle(BackgroundStyle(
                color: backgroundColor,
                cornerRadius: config.cornerRadius
            )))
        }
        
        if config.addShadow {
            styles.append(AnyStyle(ShadowStyle(
                color: config.shadowColor,
                radius: config.shadowRadius
            )))
        }
        
        return styles
    }
}
```

### Reusable Configuration Collections

Create reusable collections for common patterns:

```swift
extension Array where Element == AnyStyle {
    static var primaryCard: [AnyStyle] {
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
    
    static var secondaryCard: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 16)),
            AnyStyle(BackgroundStyle(color: .gray.opacity(0.1), cornerRadius: 12))
        ]
    }
    
    static func button(variant: ButtonVariant) -> [AnyStyle] {
        let baseStyles = [
            AnyStyle(PaddingStyle(horizontal: 16, vertical: 8)),
            AnyStyle(CornerRadiusStyle(radius: 8)),
            AnyStyle(FontStyle(font: .body.bold()))
        ]
        
        switch variant {
        case .primary:
            return baseStyles + [
                AnyStyle(BackgroundStyle(color: .blue)),
                AnyStyle(ForegroundColorStyle(color: .white))
            ]
        case .secondary:
            return baseStyles + [
                AnyStyle(BorderStyle(color: .blue, width: 1)),
                AnyStyle(ForegroundColorStyle(color: .blue))
            ]
        case .destructive:
            return baseStyles + [
                AnyStyle(BackgroundStyle(color: .red)),
                AnyStyle(ForegroundColorStyle(color: .white))
            ]
        }
    }
}

extension Array where Element == AnyListener {
    static var standardInteractions: [AnyListener] {
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
    
    static var accessibleInteractions: [AnyListener] {
        standardInteractions + [
            AnyListener(FocusListener { focused in
                announceAccessibilityChange(focused)
            })
        ]
    }
}

// Usage
VStack {
    Text("Card content")
}
.configure(
    listeners: .standardInteractions,
    styles: .primaryCard
)

Button("Submit") { }
    .configure(
        listeners: .accessibleInteractions,
        styles: .button(variant: .primary)
    )
```

## Performance Considerations

### Array Creation Optimization

Avoid creating arrays repeatedly in view body:

```swift
struct OptimizedView: View {
    // Good: Static collections
    private static let cardStyles: [AnyStyle] = [
        AnyStyle(PaddingStyle(length: 16)),
        AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12)),
        AnyStyle(ShadowStyle(radius: 4))
    ]
    
    private static let interactionListeners: [AnyListener] = [
        AnyListener(TapListener { print("Tapped") }),
        AnyListener(HoverListener { print("Hover: \($0)") })
    ]
    
    var body: some View {
        Text("Optimized")
            .configure(
                listeners: Self.interactionListeners,
                styles: Self.cardStyles
            )
    }
}
```

### Lazy Configuration

Use lazy properties for expensive configurations:

```swift
struct LazyConfiguredView: View {
    let item: ComplexItem
    
    private lazy var itemStyles: [AnyStyle] = {
        var styles = [AnyStyle(PaddingStyle(length: 16))]
        
        if item.isPriority {
            styles.append(AnyStyle(BorderStyle(color: .red, width: 2)))
        }
        
        if item.category == .premium {
            styles.append(AnyStyle(BackgroundStyle(color: .gold.opacity(0.1))))
        }
        
        return styles
    }()
    
    var body: some View {
        ItemView(item: item)
            .configure(styles: itemStyles)
    }
}
```

## Common Patterns

### Form Field Configuration

Configure form fields consistently:

```swift
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .configure(
                    listeners: [
                        AnyListener(FocusListener(
                            isFocused: focusedField == .email
                        ) { focused in
                            if focused { focusedField = .email }
                        })
                    ],
                    styles: .textField
                )
                .focused($focusedField, equals: .email)
            
            SecureField("Password", text: $password)
                .configure(
                    listeners: [
                        AnyListener(FocusListener(
                            isFocused: focusedField == .password
                        ) { focused in
                            if focused { focusedField = .password }
                        })
                    ],
                    styles: .textField
                )
                .focused($focusedField, equals: .password)
        }
    }
}

extension Array where Element == AnyStyle {
    static var textField: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 12)),
            AnyStyle(BackgroundStyle(color: .gray.opacity(0.1), cornerRadius: 8)),
            AnyStyle(BorderStyle(color: .gray.opacity(0.3), width: 1))
        ]
    }
}
```

### List Item Configuration

Configure list items with consistent styling and interactions:

```swift
struct ItemList: View {
    let items: [Item]
    
    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(items) { item in
                ItemRow(item: item)
                    .configure(
                        listeners: [
                            AnyListener(TapListener {
                                selectItem(item)
                            }),
                            AnyListener(LongPressListener {
                                showContextMenu(for: item)
                            })
                        ],
                        styles: item.isSelected ? .selectedListItem : .listItem
                    )
            }
        }
        .configure(stores: [
            AnyStore(ItemSelectionStore())
        ])
    }
}

extension Array where Element == AnyStyle {
    static var listItem: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(horizontal: 16, vertical: 12)),
            AnyStyle(BackgroundStyle(color: .clear))
        ]
    }
    
    static var selectedListItem: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(horizontal: 16, vertical: 12)),
            AnyStyle(BackgroundStyle(color: .blue.opacity(0.1), cornerRadius: 8)),
            AnyStyle(BorderStyle(color: .blue, width: 1))
        ]
    }
}
```

## See Also

- <doc:BuilderPattern>
- <doc:ResultBuilder>
- <doc:TypeErasedWrappers>
- <doc:BestPractices>
