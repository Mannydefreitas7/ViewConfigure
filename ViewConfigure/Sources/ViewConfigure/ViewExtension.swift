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
        // Use different methods based on OS version
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            for store in stores {
                view = AnyView(view.environment(AnyStore(store)))
            }
        } else {
            for store in stores {
                // For older OS versions, stores must conform to ObservableObject
                if let observableStore = store as? any ObservableObject {
                    view = AnyView(view.environmentObject(AnyStoreObservableObject(observableStore as! any Store & ObservableObject)))
                }
            }
        }

        return view
    }
}
