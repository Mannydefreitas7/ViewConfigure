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
@Observable
public class AnyStore {
    public let id: UUID
    public let objectWillChange: AnyPublisher<Void, Never>

    public init<S: Store>(_ store: S) {
        self.id = store.id
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
