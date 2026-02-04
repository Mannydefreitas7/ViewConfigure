import SwiftUI

// MARK: - Configuration Component
/// Represents a single configuration component (listener, store, or style)
public enum ConfigComponent {
    case listener(AnyListener)
    case store(any Store)
    case style(AnyStyle)
}

// MARK: - Configuration Builder
/// Result builder for creating view configurations with a declarative syntax
@resultBuilder
public struct ConfigurationBuilder {
    public static func buildBlock(_ components: ConfigComponent...) -> [ConfigComponent] {
        components
    }

    public static func buildOptional(_ component: [ConfigComponent]?) -> [ConfigComponent] {
        component ?? []
    }

    public static func buildEither(first component: [ConfigComponent]) -> [ConfigComponent] {
        component
    }

    public static func buildEither(second component: [ConfigComponent]) -> [ConfigComponent] {
        component
    }

    public static func buildArray(_ components: [[ConfigComponent]]) -> [ConfigComponent] {
        components.flatMap { $0 }
    }
}

// MARK: - Helper Functions for Cleaner Syntax
/// Creates a listener configuration component
public func listener<L: Listener>(_ l: L) -> ConfigComponent {
    .listener(AnyListener(l))
}

/// Creates a store configuration component
public func store<S: Store>(_ s: S) -> ConfigComponent {
    .store(s)
}

/// Creates a style configuration component
public func style<S: Style>(_ s: S) -> ConfigComponent {
    .style(AnyStyle(s))
}

// MARK: - View Extension for Result Builder
extension View {
    /// Configures a view using result builder syntax
    /// - Parameter content: A closure that builds configuration components
    /// - Returns: A view with all configurations applied
    public func configured(
        @ConfigurationBuilder _ content: () -> [ConfigComponent]
    ) -> some View {
        let components = content()

        let listeners = components.compactMap {
            if case .listener(let l) = $0 { return l }
            return nil
        }

        let stores = components.compactMap {
            if case .store(let s) = $0 { return s }
            return nil
        }

        let styles = components.compactMap {
            if case .style(let s) = $0 { return s }
            return nil
        }

        return configure(
            listeners: listeners,
            stores: stores,
            styles: styles
        )
    }
}
