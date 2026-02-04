import SwiftUI

// MARK: - View Extension
extension View {
    /// Configures a view with listeners, stores, and styles
    /// - Parameters:
    ///   - listeners: Array of type-erased listeners to apply event handlers
    ///   - stores: Array of stores to inject as environment objects
    ///   - styles: Array of type-erased styles to apply visual modifiers
    /// - Returns: A view with all configurations applied
    public func configure(
        listeners: [AnyListener] = [],
        stores: [any Store] = [],
        styles: [AnyStyle] = []
    ) -> some View {
        var view = AnyView(self)

        // Apply styles first
        for style in styles {
            view = style.apply(to: view)
        }

        // Apply listeners
        for listener in listeners {
            view = listener.apply(to: view)
        }

        // Inject stores as environment objects
        // Try to use @Observable first (iOS 17+), fall back to ObservableObject
        for store in stores {
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                // Use @Observable environment injection if available
                view = AnyView(view.environment(AnyStore(store)))
            } else {
                // Fall back to ObservableObject for older OS versions
                // This cast is safe because we require Store implementations to conform to ObservableObject
                // on older OS versions where @Observable is not available
                if let observableStore = store as? any ObservableObject,
                   let storeWithObservable = store as? any Store & ObservableObject {
                    view = AnyView(view.environmentObject(AnyStoreObject(storeWithObservable)))
                }
            }
        }

        return view
    }
}
