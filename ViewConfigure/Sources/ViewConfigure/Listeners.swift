import SwiftUI

public struct Listeners {

}

// MARK: - Hovering Listener
/// Listener for hover events
public struct HoverListener: Listener {
    public typealias ModifiedContent = AnyView
    public let onHover: (Bool) -> Void

    public init(onHover: @escaping (Bool) -> Void) {
        self.onHover = onHover
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.onHover(perform: onHover))
    }
}

// MARK: - Tap Listener
/// Listener for tap gesture events
public struct TapListener: Listener {
    public typealias ModifiedContent = AnyView
    public let count: Int
    public let onTap: () -> Void

    public init(count: Int = 1, onTap: @escaping () -> Void) {
        self.count = count
        self.onTap = onTap
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.onTapGesture(count: count, perform: onTap))
    }
}

// MARK: - Long Press Listener
/// Listener for long press gesture events
public struct LongPressListener: Listener {
    public typealias ModifiedContent = AnyView
    public let minimumDuration: Double
    public let onPress: () -> Void

    public init(minimumDuration: Double = 0.5, onPress: @escaping () -> Void) {
        self.minimumDuration = minimumDuration
        self.onPress = onPress
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.onLongPressGesture(
            minimumDuration: minimumDuration,
            perform: onPress
        ))
    }
}

// MARK: - Appear/Disappear Listener
/// Listener for view appear and disappear events
public struct AppearListener: Listener {
    public typealias ModifiedContent = AnyView
    public let onAppear: (() -> Void)?
    public let onDisappear: (() -> Void)?

    public init(onAppear: (() -> Void)? = nil, onDisappear: (() -> Void)? = nil) {
        self.onAppear = onAppear
        self.onDisappear = onDisappear
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content
            .onAppear {
                onAppear?()
            }
            .onDisappear {
                onDisappear?()
            }
        )
    }
}

// MARK: - Change Listener
/// Listener for value change events
public struct ChangeListener<T: Equatable>: Listener {
    public typealias ModifiedContent = AnyView
    public let value: T
    public let onChange: (T) -> Void

    public init(value: T, onChange: @escaping (T) -> Void) {
        self.value = value
        self.onChange = onChange
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.onChange(of: value) {
            onChange($0)
        })
    }
}

// MARK: - Focus Listener
/// Listener for focus state changes
public struct FocusListener: Listener {
    public typealias ModifiedContent = AnyView
    public let isFocused: Bool
    public let onFocusChange: (Bool) -> Void

    public init(isFocused: Bool, onFocusChange: @escaping (Bool) -> Void) {
        self.isFocused = isFocused
        self.onFocusChange = onFocusChange
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.onChange(of: isFocused) {
            onFocusChange($0)
        })
    }
}

// MARK: - Drag Listener
/// Listener for drag gesture events
public struct DragListener: Listener {
    public typealias ModifiedContent = AnyView
    public let onChanged: (DragGesture.Value) -> Void
    public let onEnded: ((DragGesture.Value) -> Void)?

    public init(
        onChanged: @escaping (DragGesture.Value) -> Void,
        onEnded: ((DragGesture.Value) -> Void)? = nil
    ) {
        self.onChanged = onChanged
        self.onEnded = onEnded
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.gesture(
            DragGesture()
                .onChanged(onChanged)
                .onEnded { value in
                    onEnded?(value)
                }
        ))
    }
}
