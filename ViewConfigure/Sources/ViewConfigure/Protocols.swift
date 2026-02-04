import SwiftUI

// MARK: - Listener Protocol
/// Protocol for event handlers that can be applied to views
public protocol Listener {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}

// MARK: - Store Protocol
/// Protocol for ObservableObject stores that can be injected into the environment
@Observable
public protocol Store {
    var id: UUID { get }
}

// MARK: - Style Protocol
/// Protocol for visual modifiers that can be applied to views
public protocol Style {
    associatedtype ModifiedContent: View
    func apply<Content: View>(to content: Content) -> ModifiedContent
}
