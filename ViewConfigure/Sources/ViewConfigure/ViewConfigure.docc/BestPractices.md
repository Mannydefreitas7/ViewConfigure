# Best Practices

Guidelines for effective use of ViewConfigure in your SwiftUI applications.

## Overview

Following best practices ensures you get the most out of ViewConfigure while maintaining clean, performant, and maintainable code. This guide covers architectural patterns, performance considerations, testing strategies, and common pitfalls to avoid.

## Architecture and Organization

### Component Separation

Organize your components by domain rather than type:

```swift
// Good: Domain-focused organization
struct AuthenticationComponents {
    struct LoginButtonStyle: Style { /* */ }
    struct LoginFormListener: Listener { /* */ }
    struct AuthStore: Store { /* */ }
}

struct ShoppingComponents {
    struct ProductCardStyle: Style { /* */ }
    struct AddToCartListener: Listener { /* */ }
    struct CartStore: Store { /* */ }
}

// Avoid: Type-focused organization that scatters related functionality
struct AllStyles {
    struct LoginButtonStyle: Style { /* */ }
    struct ProductCardStyle: Style { /* */ }
    struct NavigationStyle: Style { /* */ }
}
```

### Reusable Component Libraries

Create libraries of commonly used configurations:

```swift
extension Array where Element == AnyStyle {
    // Button variants
    static var primaryButton: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(horizontal: 16, vertical: 8)),
            AnyStyle(BackgroundStyle(color: .blue, cornerRadius: 8)),
            AnyStyle(ForegroundColorStyle(color: .white)),
            AnyStyle(FontStyle(font: .body.bold()))
        ]
    }
    
    static var secondaryButton: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(horizontal: 16, vertical: 8)),
            AnyStyle(BorderStyle(color: .blue, width: 1)),
            AnyStyle(BackgroundStyle(color: .clear, cornerRadius: 8)),
            AnyStyle(ForegroundColorStyle(color: .blue)),
            AnyStyle(FontStyle(font: .body.bold()))
        ]
    }
    
    // Card variants
    static var elevatedCard: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 16)),
            AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12)),
            AnyStyle(ShadowStyle(color: .black.opacity(0.1), radius: 8, x: 0, y: 4))
        ]
    }
    
    static var flatCard: [AnyStyle] {
        [
            AnyStyle(PaddingStyle(length: 16)),
            AnyStyle(BackgroundStyle(color: .gray.opacity(0.1), cornerRadius: 8))
        ]
    }
}

// Usage throughout your app
Button("Submit") { }
    .configure(styles: .primaryButton)

VStack {
    Text("Card content")
}
.configure(styles: .elevatedCard)
```

### Design Token Integration

Use design tokens for consistent styling:

```swift
struct DesignTokens {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        
        static let surface = Color.white
        static let background = Color(UIColor.systemBackground)
        static let text = Color.primary
        static let textSecondary = Color.secondary
    }
    
    enum Typography {
        static let headline = Font.largeTitle.bold()
        static let title = Font.title2.bold()
        static let body = Font.body
        static let caption = Font.caption
    }
    
    enum Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
    }
}

// Use tokens in your styles
@Register(.style)
struct PrimaryCardStyle: Style {
    func apply<Content: View>(to content: Content) -> some View {
        content
            .padding(DesignTokens.Spacing.md)
            .background(DesignTokens.Colors.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
```

## Performance Optimization

### Minimize View Updates

Be selective about what properties trigger view updates:

```swift
class OptimizedStore: Store {
    let id = UUID()
    
    // Published: UI-relevant state
    @Published var visibleItems: [Item] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Not published: Internal state
    private var allItems: [Item] = []
    private var lastFetchTime: Date?
    private var cache: [String: Item] = [:]
    
    required init() {}
    
    func refreshItems() {
        isLoading = true
        
        // Batch updates to minimize view refreshes
        Task {
            let newItems = await fetchItems()
            
            await MainActor.run {
                self.allItems = newItems
                self.visibleItems = Array(newItems.prefix(20)) // Only show first 20
                self.lastFetchTime = Date()
                self.isLoading = false
            }
        }
    }
}
```

### Efficient Style Composition

Reuse style collections instead of creating them repeatedly:

```swift
// Good: Reusable collections
struct StyleLibrary {
    static let cardBase: [AnyStyle] = [
        AnyStyle(PaddingStyle(length: 16)),
        AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12))
    ]
    
    static let cardElevated: [AnyStyle] = cardBase + [
        AnyStyle(ShadowStyle(color: .black.opacity(0.1), radius: 4))
    ]
    
    static let cardHighlighted: [AnyStyle] = cardBase + [
        AnyStyle(BorderStyle(color: .blue, width: 2))
    ]
}

// Avoid: Creating collections in view body
struct MyView: View {
    var body: some View {
        VStack {
            ForEach(items) { item in
                ItemView(item: item)
                    .configure(styles: [  // Don't create arrays repeatedly
                        AnyStyle(PaddingStyle(length: 16)),
                        AnyStyle(BackgroundStyle(color: .white, cornerRadius: 12))
                    ])
            }
        }
    }
}
```

### Lazy Configuration

Use lazy loading for expensive configurations:

```swift
struct LazyConfiguredView: View {
    let item: Item
    
    // Lazy computed properties for expensive configurations
    private var styles: [AnyStyle] {
        var styles = StyleLibrary.cardBase
        
        if item.isPriority {
            styles.append(AnyStyle(BorderStyle(color: .red, width: 2)))
        }
        
        if item.isNew {
            styles.append(AnyStyle(BadgeStyle(text: "NEW", color: .green)))
        }
        
        return styles
    }
    
    var body: some View {
        ItemContentView(item: item)
            .configure(styles: styles)
    }
}
```

## State Management

### Store Granularity

Create focused stores rather than monolithic ones:

```swift
// Good: Focused stores
class UserProfileStore: Store {
    // Only handles user profile data
    @Published var profile: UserProfile?
    @Published var isEditing: Bool = false
}

class UserPreferencesStore: Store {
    // Only handles user preferences
    @Published var theme: Theme = .system
    @Published var fontSize: FontSize = .medium
}

class UserAuthStore: Store {
    // Only handles authentication
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
}

// Avoid: Monolithic store
class UserStore: Store {
    @Published var profile: UserProfile?
    @Published var preferences: UserPreferences?
    @Published var authToken: String?
    @Published var isAuthenticated: Bool = false
    @Published var theme: Theme = .system
    @Published var recentActivity: [Activity] = []
    // Too many responsibilities!
}
```

### Store Communication

Use proper patterns for store-to-store communication:

```swift
class AppCoordinator: ObservableObject {
    let authStore = UserAuthStore()
    let preferencesStore = UserPreferencesStore()
    let dataStore = AppDataStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupStoreCoordination()
    }
    
    private func setupStoreCoordination() {
        // Clear data when user logs out
        authStore.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if !isAuthenticated {
                    self?.dataStore.clearUserData()
                    self?.preferencesStore.resetToDefaults()
                }
            }
            .store(in: &cancellables)
        
        // Load preferences when user logs in
        authStore.$currentUser
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.preferencesStore.loadPreferences(for: user.id)
            }
            .store(in: &cancellables)
    }
}
```

## Error Handling

### Graceful Degradation

Handle errors gracefully in listeners and styles:

```swift
@Register(.listener)
struct SafeNetworkListener: Listener {
    let onSuccess: (Data) -> Void
    let onError: ((Error) -> Void)?
    
    func apply<Content: View>(to content: Content) -> some View {
        content.onTapGesture {
            Task {
                do {
                    let data = try await NetworkService.shared.fetchData()
                    await MainActor.run {
                        onSuccess(data)
                    }
                } catch {
                    await MainActor.run {
                        onError?(error)
                    }
                }
            }
        }
    }
}

@Register(.style)
struct SafeImageBackgroundStyle: Style {
    let imageName: String
    let fallbackColor: Color
    
    func apply<Content: View>(to content: Content) -> some View {
        content.background(
            Group {
                if let image = UIImage(named: imageName) {
                    Image(uiImage: image)
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

### Error State Management

Provide clear error states in stores:

```swift
class RobustDataStore: Store {
    let id = UUID()
    
    @Published var items: [Item] = []
    @Published var loadingState: LoadingState = .idle
    @Published var errorState: ErrorState?
    
    enum LoadingState {
        case idle, loading, loaded, failed
    }
    
    enum ErrorState {
        case networkError(String)
        case authenticationError
        case dataCorruption
        case unknown(Error)
        
        var localizedDescription: String {
            switch self {
            case .networkError(let message):
                return "Network Error: \(message)"
            case .authenticationError:
                return "Please log in again"
            case .dataCorruption:
                return "Data corruption detected. Please refresh."
            case .unknown(let error):
                return error.localizedDescription
            }
        }
        
        var isRecoverable: Bool {
            switch self {
            case .networkError, .authenticationError:
                return true
            case .dataCorruption, .unknown:
                return false
            }
        }
    }
    
    required init() {}
    
    func loadItems() async {
        loadingState = .loading
        errorState = nil
        
        do {
            let fetchedItems = try await APIService.fetchItems()
            
            await MainActor.run {
                self.items = fetchedItems
                self.loadingState = .loaded
            }
        } catch let error as NetworkError {
            await MainActor.run {
                self.loadingState = .failed
                self.errorState = .networkError(error.message)
            }
        } catch {
            await MainActor.run {
                self.loadingState = .failed
                self.errorState = .unknown(error)
            }
        }
    }
    
    func retryIfRecoverable() {
        guard let error = errorState, error.isRecoverable else { return }
        
        Task {
            await loadItems()
        }
    }
}
```

## Testing Strategies

### Testable Components

Design components to be easily testable:

```swift
// Protocol for dependency injection
protocol DataServiceProtocol {
    func fetchItems() async throws -> [Item]
}

class TestableStore: Store {
    let id = UUID()
    
    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    
    private let dataService: DataServiceProtocol
    
    // Production initializer
    required init() {
        self.dataService = ProductionDataService()
    }
    
    // Test initializer
    init(dataService: DataServiceProtocol) {
        self.id = UUID()
        self.dataService = dataService
    }
    
    func loadItems() async {
        isLoading = true
        do {
            items = try await dataService.fetchItems()
        } catch {
            // Handle error
        }
        isLoading = false
    }
}

// Test implementation
class MockDataService: DataServiceProtocol {
    var itemsToReturn: [Item] = []
    var shouldThrowError: Error?
    
    func fetchItems() async throws -> [Item] {
        if let error = shouldThrowError {
            throw error
        }
        return itemsToReturn
    }
}

// Unit test
class TestableStoreTests: XCTestCase {
    func testLoadItems() async {
        let mockService = MockDataService()
        mockService.itemsToReturn = [Item(id: "1", name: "Test")]
        
        let store = TestableStore(dataService: mockService)
        
        await store.loadItems()
        
        XCTAssertFalse(store.isLoading)
        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.items.first?.name, "Test")
    }
}
```

### Component Testing

Test individual components in isolation:

```swift
struct TestableStyle: Style {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

// Test in SwiftUI preview or UI test
struct StyleTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Default")
            
            Text("Blue Background")
                .configured {
                    style(TestableStyle(backgroundColor: .blue, cornerRadius: 8))
                }
            
            Text("Red Background")
                .configured {
                    style(TestableStyle(backgroundColor: .red, cornerRadius: 16))
                }
        }
        .padding()
    }
}
```

## Accessibility Considerations

### Accessible Components

Ensure your components support accessibility features:

```swift
@Register(.style)
struct AccessibleButtonStyle: Style {
    let backgroundColor: Color
    let foregroundColor: Color
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            // Ensure sufficient contrast
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to activate")
    }
}

@Register(.listener)
struct AccessibleTapListener: Listener {
    let action: () -> Void
    let accessibilityLabel: String?
    let accessibilityHint: String?
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .onTapGesture(perform: action)
            .accessibilityAction(.default, action)
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityHint(accessibilityHint ?? "")
    }
}
```

### Dynamic Type Support

Support Dynamic Type in your styles:

```swift
@Register(.style)
struct DynamicTypeFontStyle: Style {
    let textStyle: Font.TextStyle
    let weight: Font.Weight
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .font(.system(textStyle, weight: weight))
            // Automatically scales with Dynamic Type
    }
}

// Usage
Text("Scalable text")
    .configured {
        style(Styles.dynamicTypeFontStyle)
    }
```

## Common Pitfalls

### Avoid Overuse

Don't use ViewConfigure for simple, single modifications:

```swift
// Overkill for simple modifications
Text("Hello")
    .configured {
        style(ForegroundColorStyle(color: .blue))
    }

// Better: Use SwiftUI directly
Text("Hello")
    .foregroundColor(.blue)

// Good use of ViewConfigure: Complex combinations
Text("Complex styling")
    .configured {
        style(PaddingStyle(length: 16))
        style(BackgroundStyle(color: .blue, cornerRadius: 8))
        style(ForegroundColorStyle(color: .white))
        style(FontStyle(font: .headline.bold()))
        listener(TapListener { print("Tapped") })
    }
```

### Store Lifecycle Management

Properly manage store lifecycles:

```swift
// Good: Store at appropriate scope
struct UserDashboard: View {
    var body: some View {
        TabView {
            ProfileTab()
            SettingsTab()
            ActivityTab()
        }
        .configured {
            // User-scoped store for entire dashboard
            store(UserStore())
        }
    }
}

// Avoid: Store at wrong scope
struct SmallWidget: View {
    var body: some View {
        Text("Widget")
            .configured {
                // Overkill: Heavy store for simple widget
                store(CompleteApplicationStore())
            }
    }
}
```

### Memory Management

Be aware of retain cycles in closures:

```swift
class MyViewController: UIViewController {
    var store: MyStore?
    
    var body: some View {
        Button("Action") { }
            .configured {
                // Bad: Strong reference cycle
                listener(TapListener {
                    self.store?.performAction()
                })
                
                // Good: Weak reference
                listener(TapListener { [weak self] in
                    self?.store?.performAction()
                })
            }
    }
}
```

## See Also

- <doc:Performance>
- <doc:Testing>
- <doc:CreatingCustomComponents>
- <doc:Protocols>
