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
/// Concrete implementations should conform to either ObservableObject (for backward compatibility)
/// or use @Observable (for iOS 17+/macOS 14+)
public protocol Store {
    var id: UUID { get }
}

// MARK: - Style Protocol
/// Protocol for visual modifiers that can be applied to views
public protocol Style {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
