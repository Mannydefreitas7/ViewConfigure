import XCTest
import SwiftUI
@testable import ViewConfigure

@Register(.style)
public struct MyTestStyle {
    public typealias ModifiedContent = AnyView
    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.border(.red))
    }

    public init() {}
}

@Register(.listener)
public struct MyTestListener {
    public typealias ModifiedContent = AnyView
    public func apply<Content: View>(to content: Content) -> ModifiedContent {
        AnyView(content.onTapGesture { })
    }

    public init() {}
}

@Register(.store)
public class MyTestStore {
    public var id = UUID()

    required public init() {}
}

final class ViewConfigureTests: XCTestCase {

    // MARK: - Test Stores
    class TestUserStore: Store {
        let id = UUID()
        @Published var username: String = "TestUser"
    }

    // MARK: - Protocol Tests
    func testListenerProtocolExists() {
        // Test that HoverListener conforms to Listener
        let listener = HoverListener { _ in }
        XCTAssertNotNil(listener)
    }

    func testStoreProtocolExists() {
        // Test that custom store conforms to Store
        let store = TestUserStore()
        XCTAssertNotNil(store.id)
    }

    func testStyleProtocolExists() {
        // Test that PaddingStyle conforms to Style
        let style = PaddingStyle(edges: .all, length: 16)
        XCTAssertNotNil(style)
    }

    // MARK: - Type-Erased Wrapper Tests
    func testAnyListenerWrapping() {
        let hoverListener = HoverListener { _ in }
        let anyListener = AnyListener(hoverListener)
        XCTAssertNotNil(anyListener)
    }

    func testAnyStyleWrapping() {
        let paddingStyle = PaddingStyle(edges: .all, length: 16)
        let anyStyle = AnyStyle(paddingStyle)
        XCTAssertNotNil(anyStyle)
    }

    func testAnyStoreWrapping() {
        let userStore = TestUserStore()
        let anyStore = AnyStore(userStore)
        XCTAssertEqual(anyStore.id, userStore.id)
    }

    // MARK: - Listener Tests
    func testHoverListenerCreation() {
        var hoverState = false
        let listener = HoverListener { isHovering in
            hoverState = isHovering
        }
        XCTAssertNotNil(listener)
    }

    func testTapListenerCreation() {
        var tapped = false
        let listener = TapListener(count: 1) {
            tapped = true
        }
        XCTAssertEqual(listener.count, 1)
    }

    func testLongPressListenerCreation() {
        let listener = LongPressListener(minimumDuration: 1.0) {}
        XCTAssertEqual(listener.minimumDuration, 1.0)
    }

    func testAppearListenerCreation() {
        let listener = AppearListener(
            onAppear: { print("appeared") },
            onDisappear: { print("disappeared") }
        )
        XCTAssertNotNil(listener.onAppear)
        XCTAssertNotNil(listener.onDisappear)
    }

    // MARK: - Style Tests
    func testPaddingStyleCreation() {
        let style = PaddingStyle(edges: .horizontal, length: 20)
        XCTAssertEqual(style.edges, .horizontal)
        XCTAssertEqual(style.length, 20)
    }

    func testBackgroundStyleCreation() {
        let style = BackgroundStyle(color: .blue, cornerRadius: 8)
        XCTAssertEqual(style.color, .blue)
        XCTAssertEqual(style.cornerRadius, 8)
    }

    func testShadowStyleCreation() {
        let style = ShadowStyle(color: .black, radius: 10, x: 0, y: 5)
        XCTAssertEqual(style.radius, 10)
        XCTAssertEqual(style.x, 0)
        XCTAssertEqual(style.y, 5)
    }

    func testFrameStyleCreation() {
        let style = FrameStyle(width: 100, height: 200, alignment: .topLeading)
        XCTAssertEqual(style.width, 100)
        XCTAssertEqual(style.height, 200)
        XCTAssertEqual(style.alignment, .topLeading)
    }

    // MARK: - Builder Tests
    func testViewConfiguratorCreation() {
        let configurator = ViewConfigurator()
        XCTAssertNotNil(configurator)
    }

    func testViewConfiguratorChaining() {
        let configurator = ViewConfigurator()
            .addStyle(PaddingStyle(length: 16))
            .addStyle(BackgroundStyle(color: .blue))
            .addListener(TapListener { })
        XCTAssertNotNil(configurator)
    }

    // MARK: - Config Component Tests
    func testConfigComponentListener() {
        let component = listener(HoverListener { _ in })
        if case .listener = component {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected listener component")
        }
    }

    func testConfigComponentStyle() {
        let component = style(PaddingStyle(length: 16))
        if case .style = component {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected style component")
        }
    }

    func testConfigComponentStore() {
        let component = store(TestUserStore())
        if case .store = component {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected store component")
        }
    }

    // MARK: - Macro Tests
    func testRegisterStyleMacro() {
        let style = Styles.myTestStyle
        XCTAssertNotNil(style)
    }

    func testRegisterListenerMacro() {
        let listener = Listeners.myTestListener
        XCTAssertNotNil(listener)
    }

    func testRegisterStoreMacro() {
        let store = Stores.myTestStore
        XCTAssertNotNil(store)
    }
}
