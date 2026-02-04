// ViewConfigure
// A Swift Package for organizing SwiftUI view configuration with listeners, stores, and styles.

// Re-export all public APIs
@_exported import SwiftUI

// This file serves as the main entry point for the ViewConfigure package.
// All components are organized in separate files:
//
// - Protocols.swift: Core protocols (Listener, Store, Style)
// - TypeErasedWrappers.swift: Type-erased wrappers (AnyListener, AnyStore, AnyStyle)
// - Listeners.swift: Concrete listener implementations
// - Styles.swift: Concrete style implementations
// - ViewExtension.swift: View extension with configure() method
// - Builder.swift: ViewConfigurator builder pattern
// - ResultBuilder.swift: @ConfigurationBuilder result builder
