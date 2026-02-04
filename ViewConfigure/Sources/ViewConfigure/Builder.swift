import SwiftUI

// MARK: - View Configurator (Builder Pattern)
/// Builder for creating view configurations with a fluent API
public struct ViewConfigurator {
    private var listeners: [AnyListener] = []
    private var stores: [any Store] = []
    private var styles: [AnyStyle] = []

    public init() {}

    /// Adds a listener to the configuration
    public func addListener<L: Listener>(_ listener: L) -> ViewConfigurator {
        var config = self
        config.listeners.append(AnyListener(listener))
        return config
    }

    /// Adds a store to the configuration
    public func addStore<S: Store>(_ store: S) -> ViewConfigurator {
        var config = self
        config.stores.append(store)
        return config
    }

    /// Adds a style to the configuration
    public func addStyle<S: Style>(_ style: S) -> ViewConfigurator {
        var config = self
        config.styles.append(AnyStyle(style))
        return config
    }

    /// Applies the configuration to a view
    public func apply(to view: some View) -> some View {
        view.configure(
            listeners: listeners,
            stores: stores,
            styles: styles
        )
    }
}

// MARK: - View Extension for Builder Pattern
extension View {
    /// Configures a view using a builder closure
    /// - Parameter builder: A closure that configures a ViewConfigurator
    /// - Returns: A view with the configuration applied
    public func configured(_ builder: (ViewConfigurator) -> ViewConfigurator) -> some View {
        builder(ViewConfigurator()).apply(to: self)
    }
}
