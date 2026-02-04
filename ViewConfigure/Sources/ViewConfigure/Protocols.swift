import SwiftUI
import Combine

// MARK: - Listener Protocol
/// Protocol for event handlers that can be applied to views
public protocol Listener {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}

// MARK: - Store Protocol
/// Protocol for stores that can be injected into the environment
/// Implementations should conform to ObservableObject or use @Observable based on target OS version
public protocol Store {
    var id: UUID { get }
}

// MARK: - Style Protocol
/// Protocol for visual modifiers that can be applied to views
public protocol Style {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
