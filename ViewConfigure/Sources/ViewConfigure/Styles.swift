import SwiftUI

public struct Styles {

}

// MARK: - Padding Style
/// Style for applying padding to views
public struct PaddingStyle: Style {
    public typealias ModifiedContent = AnyView
    public let edges: Edge.Set
    public let length: CGFloat?

    public init(edges: Edge.Set = .all, length: CGFloat? = nil) {
        self.edges = edges
        self.length = length
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        if let length = length {
            return AnyView(content.padding(edges, length))
        } else {
            return AnyView(content.padding(edges))
        }
    }
}

// MARK: - Background Style
/// Style for applying background to views
public struct BackgroundStyle: Style {
    public typealias ModifiedContent = AnyView
    public let color: Color
    public let cornerRadius: CGFloat?

    public init(color: Color, cornerRadius: CGFloat? = nil) {
        self.color = color
        self.cornerRadius = cornerRadius
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        if let radius = cornerRadius {
            return AnyView(
                content
                    .background(color)
                    .cornerRadius(radius)
            )
        } else {
            return AnyView(content.background(color))
        }
    }
}

// MARK: - Shadow Style
/// Style for applying shadow to views
public struct ShadowStyle: Style {
    public typealias ModifiedContent = AnyView
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(
        color: Color = .black.opacity(0.2),
        radius: CGFloat = 5,
        x: CGFloat = 0,
        y: CGFloat = 2
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.shadow(color: color, radius: radius, x: x, y: y))
    }
}

// MARK: - Frame Style
/// Style for applying frame constraints to views
public struct FrameStyle: Style {
    public typealias ModifiedContent = AnyView
    public let width: CGFloat?
    public let height: CGFloat?
    public let alignment: Alignment

    public init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.frame(
            width: width,
            height: height,
            alignment: alignment
        ))
    }
}

// MARK: - Corner Radius Style
/// Style for applying corner radius to views
public struct CornerRadiusStyle: Style {
    public typealias ModifiedContent = AnyView
    public let radius: CGFloat

    public init(radius: CGFloat) {
        self.radius = radius
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.cornerRadius(radius))
    }
}

// MARK: - Border Style
/// Style for applying border to views
public struct BorderStyle: Style {
    public typealias ModifiedContent = AnyView
    public let color: Color
    public let width: CGFloat

    public init(color: Color, width: CGFloat = 1) {
        self.color = color
        self.width = width
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.border(color, width: width))
    }
}

// MARK: - Opacity Style
/// Style for applying opacity to views
public struct OpacityStyle: Style {
    public typealias ModifiedContent = AnyView
    public let opacity: Double

    public init(opacity: Double) {
        self.opacity = opacity
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.opacity(opacity))
    }
}

// MARK: - Foreground Color Style
/// Style for applying foreground color to views
public struct ForegroundColorStyle: Style {
    public typealias ModifiedContent = AnyView
    public let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.foregroundColor(color))
    }
}

// MARK: - Font Style
/// Style for applying font to views
public struct FontStyle: Style {
    public typealias ModifiedContent = AnyView
    public let font: Font

    public init(font: Font) {
        self.font = font
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.font(font))
    }
}

#if os(macOS)
// MARK: - Titlebar Style (macOS)
/// Style for controlling titlebar visibility on macOS
@available(macOS 13.0, *)
public struct TitlebarStyle: Style {
    public typealias ModifiedContent = AnyView
    public let hidden: Bool

    public init(hidden: Bool = false) {
        self.hidden = hidden
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        if hidden {
            return AnyView(content.toolbar(.hidden, for: .windowToolbar))
        } else {
            return AnyView(content)
        }
    }
}
#endif

// MARK: - Clip Shape Style
/// Style for applying clip shape to views
public struct ClipShapeStyle<S: Shape>: Style {
    public typealias ModifiedContent = AnyView
    public let shape: S

    public init(shape: S) {
        self.shape = shape
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.clipShape(shape))
    }
}

// MARK: - Disabled Style
/// Style for disabling view interaction
public struct DisabledStyle: Style {
    public typealias ModifiedContent = AnyView
    public let isDisabled: Bool

    public init(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }

    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.disabled(isDisabled))
    }
}
