import XCTest

final class PanelStateTests: XCTestCase {

    func testFreshKeyboardStartsExpanded() {
        let state = PanelState()
        XCTAssertFalse(state.isCollapsed)
        XCTAssertEqual(state.height, PanelState.expandedHeight)
    }

    func testCollapsedFootprintIsOnePoint() {
        // The product contract: collapsed TinyKeyboard is exactly 1pt tall.
        XCTAssertEqual(PanelState.collapsedHeight, 1)
        var state = PanelState()
        state.collapse()
        XCTAssertTrue(state.isCollapsed)
        XCTAssertEqual(state.height, 1)
    }

    func testCollapseIsIdempotent() {
        var state = PanelState()
        state.collapse()
        state.collapse()
        XCTAssertEqual(state, PanelState(isCollapsed: true))
    }

    func testExpandedPanelFitsATapTarget() {
        XCTAssertGreaterThanOrEqual(PanelState.expandedHeight, 44)
    }
}
