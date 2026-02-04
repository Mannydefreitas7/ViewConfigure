# Creating Custom Components

Learn how to create custom listeners, stores, and styles to extend ViewConfigure's functionality.

## Overview

ViewConfigure's power comes from its extensibility. You can create custom components that integrate seamlessly with the built-in configuration system by conforming to the core protocols: `Listener`, `Store`, and `Style`.

This guide covers:
- Implementing custom listeners for unique interactions
- Building custom stores for specialized state management
- Creating custom styles for advanced visual effects
- Using the `@Register` macro for automatic registration
- Best practices for component design

## Creating Custom Listeners

### Basic Custom Listener

A listener handles user interactions or system events. Here's a simple example:

```swift
import SwiftUI
import ViewConfigure

struct DoubleClickListener: Listener {
    let action: () -> Void
    let delay: TimeInterval
    
    init(delay: TimeInterval = 0.3, action: @escaping () -> Void) {
        self.delay = delay
        self.action = action
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.onReceive(doubleClickPublisher) { _ in
            action()
        }
    }
    
    private var doubleClickPublisher: AnyPublisher<Void, Never> {
        // Implementation for double-click detection
        NotificationCenter.default
            .publisher(for: .doubleClick)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
```

### Advanced Gesture Listener

Create complex gesture handling:

```swift
struct SwipeListener: Listener {
    enum Direction {
        case up, down, left, right
    }
    
    let direction: Direction
    let minimumDistance: CGFloat
    let action: () -> Void
    
    init(
        direction: Direction,
        minimumDistance: CGFloat = 50,
        action: @escaping () -> Void
    ) {
        self.direction = direction
        self.minimumDistance = minimumDistance
        self.action = action
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.x
                    let verticalAmount = value.translation.y
                    
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        // Horizontal swipe
                        if horizontalAmount > minimumDistance && direction == .right {
                            action()
                        } else if horizontalAmount < -minimumDistance && direction == .left {
                            action()
                        }
                    } else {
                        // Vertical swipe
                        if verticalAmount > minimumDistance && direction == .down {
                            action()
                        } else if verticalAmount < -minimumDistance && direction == .up {
                            action()
                        }
                    }
                }
        )
    }
}
```

### Keyboard Event Listener

Handle keyboard events (macOS):

```swift
#if os(macOS)
struct KeyboardListener: Listener {
    let key: KeyEquivalent
    let modifiers: EventModifiers
    let action: () -> Void
    
    init(
        key: KeyEquivalent,
        modifiers: EventModifiers = [],
        action: @escaping () -> Void
    ) {
        self.key = key
        self.modifiers = modifiers
        self.action = action
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.onReceive(keyEventPublisher) { _ in
            action()
        }
    }
    
    private var keyEventPublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: NSApplication.keyDownNotification)
            .compactMap { notification in
                guard let event = notification.object as? NSEvent else { return nil }
                // Check if the key matches our target
                return matchesKeyEvent(event) ? () : nil
            }
            .eraseToAnyPublisher()
    }
    
    private func matchesKeyEvent(_ event: NSEvent) -> Bool {
        // Implementation to match key and modifiers
        return event.charactersIgnoringModifiers == String(key.character) &&
               event.modifierFlags.contains(NSEvent.ModifierFlags(modifiers))
    }
}
#endif
```

## Creating Custom Stores

### Simple State Store

Create a store for managing specific application state:

```swift
import ViewConfigure
import Combine

class NotificationStore: Store {
    let id = UUID()
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    @Published var isEnabled: Bool = true
    
    required init() {
        setupUnreadCountBinding()
    }
    
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        updateUnreadCount()
    }
    
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    func clearAll() {
        notifications.removeAll()
        unreadCount = 0
    }
    
    private func setupUnreadCountBinding() {
        $notifications
            .map { notifications in
                notifications.filter { !$0.isRead }.count
            }
            .assign(to: &$unreadCount)
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
}
```

### Network-Aware Store

Create a store that handles network operations:

```swift
import ViewConfigure
import Combine
import Foundation

class WeatherStore: Store {
    let id = UUID()
    
    @Published var currentWeather: Weather?
    @Published var forecast: [Weather] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    
    private let apiService: WeatherAPIService
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    required init() {
        self.apiService = WeatherAPIService()
        self.locationManager = LocationManager()
        setupLocationUpdates()
    }
    
    // Test initializer for dependency injection
    init(apiService: WeatherAPIService, locationManager: LocationManager) {
        self.id = UUID()
        self.apiService = apiService
        self.locationManager = locationManager
        setupLocationUpdates()
    }
    
    func refreshWeather() async {
        guard let location = locationManager.currentLocation else {
            errorMessage = "Location not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            async let weatherTask = apiService.getCurrentWeather(for: location)
            async let forecastTask = apiService.getForecast(for: location)
            
            currentWeather = try await weatherTask
            forecast = try await forecastTask
            lastUpdateTime = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func setupLocationUpdates() {
        locationManager.locationPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshWeather()
                }
            }
            .store(in: &cancellables)
    }
}
```

### Persistence-Enabled Store

Create a store that automatically persists its state:

```swift
import ViewConfigure
import Combine
import Foundation

class UserPreferencesStore: Store, Codable {
    let id = UUID()
    
    @Published var theme: Theme = .system {
        didSet { save() }
    }
    
    @Published var fontSize: FontSize = .medium {
        didSet { save() }
    }
    
    @Published var notificationsEnabled: Bool = true {
        didSet { save() }
    }
    
    @Published var language: Language = .system {
        didSet { save() }
    }
    
    private static let storageKey = "UserPreferences"
    
    required init() {
        load()
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case theme, fontSize, notificationsEnabled, language
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(theme, forKey: .theme)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(language, forKey: .language)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = try container.decode(Theme.self, forKey: .theme)
        fontSize = try container.decode(FontSize.self, forKey: .fontSize)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        language = try container.decode(Language.self, forKey: .language)
    }
    
    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } catch {
            print("Failed to save preferences: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let preferences = try? JSONDecoder().decode(UserPreferencesStore.self, from: data) else {
            return
        }
        
        theme = preferences.theme
        fontSize = preferences.fontSize
        notificationsEnabled = preferences.notificationsEnabled
        language = preferences.language
    }
}
```

## Creating Custom Styles

### Advanced Visual Effect Style

Create complex visual effects:

```swift
import SwiftUI
import ViewConfigure

struct NeonGlowStyle: Style {
    let color: Color
    let intensity: Double
    let animated: Bool
    
    init(color: Color, intensity: Double = 1.0, animated: Bool = false) {
        self.color = color
        self.intensity = intensity
        self.animated = animated
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .blur(radius: 2 * intensity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
                    .blur(radius: 1 * intensity)
            )
            .shadow(color: color, radius: 4 * intensity, x: 0, y: 0)
            .scaleEffect(animated ? 1.02 : 1.0)
            .animation(
                animated ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : nil,
                value: animated
            )
    }
}
```

### Responsive Layout Style

Create styles that adapt to different screen sizes:

```swift
struct ResponsivePaddingStyle: Style {
    let compact: CGFloat
    let regular: CGFloat
    
    init(compact: CGFloat, regular: CGFloat) {
        self.compact = compact
        self.regular = regular
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.modifier(ResponsivePaddingModifier(compact: compact, regular: regular))
    }
}

private struct ResponsivePaddingModifier: ViewModifier {
    let compact: CGFloat
    let regular: CGFloat
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        content.padding(horizontalSizeClass == .compact ? compact : regular)
    }
}
```

### Conditional Platform Style

Create platform-specific styling:

```swift
struct PlatformAdaptiveStyle: Style {
    let iOSStyle: AnyStyle?
    let macOSStyle: AnyStyle?
    let tvOSStyle: AnyStyle?
    let watchOSStyle: AnyStyle?
    
    init(
        iOS: (any Style)? = nil,
        macOS: (any Style)? = nil,
        tvOS: (any Style)? = nil,
        watchOS: (any Style)? = nil
    ) {
        self.iOSStyle = iOS.map(AnyStyle.init)
        self.macOSStyle = macOS.map(AnyStyle.init)
        self.tvOSStyle = tvOS.map(AnyStyle.init)
        self.watchOSStyle = watchOS.map(AnyStyle.init)
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        let platformStyle: AnyStyle? = {
            #if os(iOS)
            return iOSStyle
            #elseif os(macOS)
            return macOSStyle
            #elseif os(tvOS)
            return tvOSStyle
            #elseif os(watchOS)
            return watchOSStyle
            #else
            return nil
            #endif
        }()
        
        if let style = platformStyle {
            return style.apply(to: content)
        } else {
            return AnyView(content)
        }
    }
}
```

## Using the @Register Macro

The `@Register` macro automatically adds your custom components to the appropriate namespace:

### Registering Custom Styles

```swift
@Register(.style)
struct GlassEffectStyle: Style {
    let opacity: Double
    
    init(opacity: Double = 0.8) {
        self.opacity = opacity
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .opacity(opacity)
    }
}

// Usage: Available as Styles.glassEffectStyle
Text("Glassy")
    .configured {
        style(Styles.glassEffectStyle)
    }
```

### Registering Custom Listeners

```swift
@Register(.listener)
struct ShakeGestureListener: Listener {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.onReceive(shakeNotification) { _ in
            action()
        }
    }
    
    private var shakeNotification: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)
    }
}

// Usage: Available as Listeners.shakeGestureListener
Text("Shake me")
    .configured {
        listener(Listeners.shakeGestureListener)
    }
```

### Registering Custom Stores

```swift
@Register(.store)
class GameStateStore: Store {
    let id = UUID()
    
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var lives: Int = 3
    @Published var isGameOver: Bool = false
    
    required init() {}
    
    func increaseScore(by points: Int) {
        score += points
        checkLevelUp()
    }
    
    func loseLife() {
        lives -= 1
        if lives <= 0 {
            isGameOver = true
        }
    }
    
    func reset() {
        score = 0
        level = 1
        lives = 3
        isGameOver = false
    }
    
    private func checkLevelUp() {
        let newLevel = (score / 1000) + 1
        if newLevel > level {
            level = newLevel
        }
    }
}

// Usage: Available as Stores.gameStateStore
GameView()
    .configured {
        store(Stores.gameStateStore)
    }
```

## Component Design Best Practices

### Single Responsibility Principle

Each component should have one clear purpose:

```swift
// Good: Focused on one interaction
struct HoverScaleListener: Listener {
    let scale: CGFloat
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .scaleEffect(isHovering ? scale : 1.0)
            .onHover { isHovering = $0 }
    }
}

// Avoid: Multiple responsibilities
struct ComplexInteractionListener: Listener {
    // Handles hover, tap, long press, and drag - too much!
}
```

### Configuration Through Initialization

Make components configurable through their initializers:

```swift
struct AnimatedPaddingStyle: Style {
    let length: CGFloat
    let duration: TimeInterval
    let curve: Animation
    
    init(
        length: CGFloat,
        duration: TimeInterval = 0.3,
        curve: Animation = .easeInOut
    ) {
        self.length = length
        self.duration = duration
        self.curve = curve
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .padding(length)
            .animation(curve.speed(1/duration), value: length)
    }
}
```

### Error Handling

Handle edge cases gracefully:

```swift
struct SafeImageStyle: Style {
    let imageName: String
    let fallbackColor: Color
    
    init(imageName: String, fallbackColor: Color = .gray) {
        self.imageName = imageName
        self.fallbackColor = fallbackColor
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content.background(
            Group {
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    fallbackColor
                }
            }
        )
    }
}
```

### Performance Considerations

- **Minimize view updates**: Only publish properties that need to trigger UI updates
- **Use efficient animations**: Prefer transform-based animations over layout changes
- **Cache expensive operations**: Store computed results when possible

```swift
class OptimizedImageStore: Store {
    let id = UUID()
    
    @Published var displayImages: [ProcessedImage] = []
    
    // Not published - internal cache
    private var imageCache: [String: ProcessedImage] = [:]
    private let imageProcessor = ImageProcessor()
    
    required init() {}
    
    func loadImage(url: String) async {
        if let cached = imageCache[url] {
            displayImages.append(cached)
            return
        }
        
        let processed = await imageProcessor.process(url: url)
        imageCache[url] = processed
        displayImages.append(processed)
    }
}
```

## See Also

- <doc:Protocols>
- <doc:RegisterMacro>
- <doc:BestPractices>
- <doc:Testing>
