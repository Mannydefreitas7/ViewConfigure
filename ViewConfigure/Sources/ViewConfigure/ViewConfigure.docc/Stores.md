# Stores

Manage application state with observable store components that integrate with SwiftUI's environment system.

## Overview

Stores in ViewConfigure provide a way to manage and share application state across your SwiftUI view hierarchy. Each store conforms to the ``Store`` protocol and integrates seamlessly with SwiftUI's environment system and observation framework.

Stores are designed to be:
- **Observable**: Automatically trigger view updates when state changes
- **Injectable**: Easily shared across view hierarchies through environment injection  
- **Identifiable**: Each store instance has a unique identifier
- **Instantiable**: Support automatic instantiation with parameterless initializers
- **Composable**: Multiple stores can work together in complex applications

## Store Protocol

The `Store` protocol extends `ObservableObject` and requires two key components:

```swift
public protocol Store: ObservableObject {
    var id: UUID { get }
    init()
}
```

### Requirements

- **ObservableObject conformance**: Enables SwiftUI reactivity through `@Published` properties
- **Unique identifier**: Each store instance must have a UUID for environment management
- **Default initializer**: Supports automatic instantiation when needed

## Creating Custom Stores

### Basic Store Implementation

```swift
import ViewConfigure
import Combine

class CounterStore: Store {
    let id = UUID()
    
    @Published var count: Int = 0
    @Published var isLoading: Bool = false
    
    required init() {}
    
    func increment() {
        count += 1
    }
    
    func decrement() {
        count -= 1
    }
    
    func reset() {
        count = 0
    }
}
```

### Advanced Store with Async Operations

```swift
class UserStore: Store {
    let id = UUID()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    required init() {
        self.authService = AuthService()
        setupObservers()
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        authService.logout()
    }
    
    private func setupObservers() {
        // Setup any additional observers or subscriptions
    }
}
```

## Using Stores in Views

### Environment Injection

Inject stores into the environment for child views to access:

```swift
struct RootView: View {
    var body: some View {
        ContentView()
            .configured {
                store(CounterStore())
                store(UserStore())
                store(ThemeStore())
            }
    }
}
```

### Accessing Stores in Child Views

Child views can access stores through SwiftUI's environment:

```swift
struct CounterView: View {
    @Environment(CounterStore.self) private var counterStore
    
    var body: some View {
        VStack {
            Text("Count: \(counterStore.count)")
            
            HStack {
                Button("−") {
                    counterStore.decrement()
                }
                
                Button("+") {
                    counterStore.increment()
                }
            }
            
            Button("Reset") {
                counterStore.reset()
            }
        }
    }
}
```

### Direct Store Usage

You can also use stores directly without environment injection:

```swift
struct DirectStoreView: View {
    @StateObject private var counterStore = CounterStore()
    
    var body: some View {
        Text("Count: \(counterStore.count)")
            .configured {
                listener(TapListener {
                    counterStore.increment()
                })
            }
    }
}
```

## Store Registration with @Register Macro

Use the `@Register` macro to automatically register stores in the `Stores` namespace:

```swift
@Register(.store)
class ShoppingCartStore: Store {
    let id = UUID()
    
    @Published var items: [CartItem] = []
    @Published var total: Decimal = 0
    
    required init() {}
    
    func addItem(_ item: CartItem) {
        items.append(item)
        updateTotal()
    }
    
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        updateTotal()
    }
    
    private func updateTotal() {
        total = items.reduce(0) { $0 + $1.price }
    }
}

// Usage: Now available as Stores.shoppingCartStore
ContentView()
    .configured {
        store(Stores.shoppingCartStore)
    }
```

## Store Patterns

### State Management Store

Manage complex application state with computed properties:

```swift
class AppStateStore: Store {
    let id = UUID()
    
    @Published var networkStatus: NetworkStatus = .unknown
    @Published var settings: AppSettings = AppSettings()
    @Published var notifications: [AppNotification] = []
    
    // Computed properties
    var isOnline: Bool {
        networkStatus == .connected
    }
    
    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    required init() {
        startNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        // Implementation for network monitoring
    }
}
```

### Data Repository Store

Manage data fetching and caching:

```swift
class PostsStore: Store {
    let id = UUID()
    
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let apiService: APIService
    private var cache: [String: Post] = [:]
    
    required init() {
        self.apiService = APIService()
    }
    
    func fetchPosts() async {
        isLoading = true
        error = nil
        
        do {
            posts = try await apiService.fetchPosts()
            cachePosts()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func getPost(id: String) -> Post? {
        return cache[id] ?? posts.first { $0.id == id }
    }
    
    private func cachePosts() {
        for post in posts {
            cache[post.id] = post
        }
    }
}
```

### Preferences Store

Manage user preferences with persistence:

```swift
class PreferencesStore: Store {
    let id = UUID()
    
    @Published var theme: Theme {
        didSet { saveTheme() }
    }
    
    @Published var fontSize: CGFloat {
        didSet { saveFontSize() }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet { saveNotificationSettings() }
    }
    
    required init() {
        self.theme = Self.loadTheme()
        self.fontSize = Self.loadFontSize()
        self.notificationsEnabled = Self.loadNotificationSettings()
    }
    
    // Persistence methods
    private func saveTheme() {
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
    }
    
    private static func loadTheme() -> Theme {
        Theme(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "") ?? .system
    }
    
    // Similar methods for other properties...
}
```

## Store Composition

### Multiple Store Coordination

Coordinate between multiple stores:

```swift
class AppCoordinator {
    let userStore: UserStore
    let preferencesStore: PreferencesStore
    let dataStore: DataStore
    
    init(userStore: UserStore, preferencesStore: PreferencesStore, dataStore: DataStore) {
        self.userStore = userStore
        self.preferencesStore = preferencesStore
        self.dataStore = dataStore
        
        setupStoreCoordination()
    }
    
    private func setupStoreCoordination() {
        // Coordinate authentication state
        userStore.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if !isAuthenticated {
                    self?.dataStore.clearCache()
                }
            }
            .store(in: &cancellables)
        
        // Sync preferences
        userStore.$currentUser
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.preferencesStore.loadUserPreferences(for: user)
            }
            .store(in: &cancellables)
    }
}
```

## Best Practices

### State Organization

- **Single responsibility**: Each store should manage one area of application state
- **Flat structure**: Avoid deeply nested state; prefer multiple focused stores
- **Computed properties**: Use computed properties for derived state

```swift
// Good: Focused responsibility
class AuthStore: Store { /* handles authentication */ }
class CartStore: Store { /* handles shopping cart */ }
class UIStore: Store { /* handles UI state */ }

// Avoid: Mixed responsibilities
class AppStore: Store { 
    /* handles authentication, cart, UI, network, etc. */ 
}
```

### Performance Considerations

- **Selective observation**: Only publish properties that need to trigger view updates
- **Batch updates**: Group related state changes together
- **Lazy loading**: Load data only when needed

```swift
class OptimizedStore: Store {
    let id = UUID()
    
    // Published: Triggers view updates
    @Published var visibleData: [Item] = []
    @Published var isLoading: Bool = false
    
    // Not published: Internal state
    private var allData: [Item] = []
    private var cache: [String: Item] = [:]
    
    required init() {}
    
    func loadVisibleItems(range: Range<Int>) {
        visibleData = Array(allData[range])
    }
}
```

### Testing

Make stores testable by injecting dependencies:

```swift
class TestableStore: Store {
    let id = UUID()
    
    @Published var data: [String] = []
    
    private let dataService: DataServiceProtocol
    
    required init() {
        self.dataService = ProductionDataService()
    }
    
    // Test initializer
    init(dataService: DataServiceProtocol) {
        self.id = UUID()
        self.dataService = dataService
    }
}

// In tests
let mockService = MockDataService()
let store = TestableStore(dataService: mockService)
```

## See Also

- ``Store``
- ``AnyStore``
- <doc:TypeErasedWrappers>
- <doc:CreatingCustomComponents>
