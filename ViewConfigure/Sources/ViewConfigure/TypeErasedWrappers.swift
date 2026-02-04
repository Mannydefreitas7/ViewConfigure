import SwiftUI
import Combine

// MARK: - Type-erased Listener
/// Type-erased wrapper for Listener protocol to allow storage in arrays
public struct AnyListener {
    private let _apply: (AnyView) -> AnyView

    public init<L: Listener>(_ listener: L) {
        _apply = { content in
            AnyView(listener.apply(to: content))
        }
    }

    public func apply(to content: some View) -> AnyView {
        _apply(AnyView(content))
    }
}

// MARK: - Type-erased Store
/// Type-erased wrapper for Store protocol to allow storage in arrays
/// Supports both @Observable (iOS 17+/macOS 14+) and ObservableObject (all versions)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
public final class AnyStore {
    public let id: UUID
    private let store: Any
    
    public init<S: Store>(_ store: S) {
        self.id = store.id
        self.store = store
    }
}

/// Type-erased wrapper for Store protocol using ObservableObject for backward compatibility
public final class AnyStoreObject: ObservableObject {
    public let id: UUID
    public let objectWillChange: AnyPublisher<Void, Never>
    private let store: Any
    
    public init<S: Store & ObservableObject>(_ store: S) {
        self.id = store.id
        self.store = store
        self.objectWillChange = store.objectWillChange.map { _ in }.eraseToAnyPublisher()
    }
}

// MARK: - Type-erased Style
/// Type-erased wrapper for Style protocol to allow storage in arrays
public struct AnyStyle {
    private let _apply: (AnyView) -> AnyView

    public init<S: Style>(_ style: S) {
        _apply = { content in
            AnyView(style.apply(to: content))
        }
    }

    public func apply(to content: some View) -> AnyView {
        _apply(AnyView(content))
    }
}
