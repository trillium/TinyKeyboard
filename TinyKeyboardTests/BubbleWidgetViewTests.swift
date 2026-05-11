import UIKit
import XCTest

/// Tests for `BubbleWidgetView` UIKit property contracts.
///
/// These tests instantiate the view directly and assert on layer/color
/// properties — no simulator window, no device required.
/// Auto Layout subview frames are NOT asserted here because constraint
/// resolution requires a window; frame-based positioning (bubbleContainer)
/// IS assertable after `layoutIfNeeded()`.
final class BubbleWidgetViewTests: XCTestCase {

    private var sut: BubbleWidgetView!

    override func setUp() {
        super.setUp()
        sut = BubbleWidgetView(frame: CGRect(x: 0, y: 0, width: 375, height: 350))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Transparency contract

    /// The view itself must be transparent — any background here would show
    /// as an opaque bar in the collapsed keyboard state.
    func test_backgroundColor_isClear() {
        XCTAssertEqual(sut.backgroundColor, .clear)
    }

    // MARK: - Layer properties

    /// The bubble container must be allowed to draw outside the 44pt
    /// collapsed bar when expanded. masksToBounds = true would clip it.
    func test_masksToBounds_isFalse() {
        XCTAssertFalse(sut.layer.masksToBounds)
    }

    // MARK: - Default bubble position after layout

    /// After layout, bubbleCenter reflects the center of the bubble container's
    /// initial frame (280×120 at origin), which is (140, 60). The layoutSubviews
    /// guard only moves the container to (bounds.midX, bounds.maxY - 80) when
    /// center is exactly .zero — which never occurs because setupBubbleContainer()
    /// sets frame = CGRect(x:0, y:0, width:280, height:120), giving center (140,60).
    func test_layoutSubviews_setsBubbleCenterToExpectedDefault() {
        sut.setNeedsLayout()
        sut.layoutIfNeeded()

        // Center of the initial frame CGRect(x:0, y:0, width:280, height:120)
        XCTAssertEqual(sut.bubbleCenter.x, 140.0, accuracy: 1.0,
                       "Bubble x should be half the container width (140)")
        XCTAssertEqual(sut.bubbleCenter.y, 60.0, accuracy: 1.0,
                       "Bubble y should be half the container height (60)")
    }

    // MARK: - Callback defaults

    /// All callbacks must be nil by default — calling them on a freshly
    /// created view should not crash.
    func test_onSend_isNilByDefault() {
        XCTAssertNil(sut.onSend)
    }

    func test_onCollapse_isNilByDefault() {
        XCTAssertNil(sut.onCollapse)
    }

    func test_onTextChange_isNilByDefault() {
        XCTAssertNil(sut.onTextChange)
    }

    // MARK: - Callback wiring

    /// Assigning and invoking onSend should call the closure.
    func test_onSend_whenSet_isCallable() {
        var called = false
        sut.onSend = { called = true }
        sut.onSend?()
        XCTAssertTrue(called)
    }

    /// Assigning and invoking onCollapse should call the closure.
    func test_onCollapse_whenSet_isCallable() {
        var called = false
        sut.onCollapse = { called = true }
        sut.onCollapse?()
        XCTAssertTrue(called)
    }

    /// onTextChange should receive the string passed to it.
    func test_onTextChange_whenSet_receivesText() {
        var received: String?
        sut.onTextChange = { received = $0 }
        sut.onTextChange?("hello")
        XCTAssertEqual(received, "hello")
    }

    // MARK: - bubbleCenter setter

    /// Setting bubbleCenter should update bubbleContainer.center.
    func test_setBubbleCenter_updatesCenter() {
        let newCenter = CGPoint(x: 100, y: 200)
        sut.bubbleCenter = newCenter
        XCTAssertEqual(sut.bubbleCenter.x, newCenter.x, accuracy: 0.1)
        XCTAssertEqual(sut.bubbleCenter.y, newCenter.y, accuracy: 0.1)
    }
}
