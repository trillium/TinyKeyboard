import XCTest
@testable import TinyKeyboardExtension

final class KeyboardStateTests: XCTestCase {

    // MARK: - Initial state

    func test_initialState_isCollapsed() {
        let state = KeyboardState()
        XCTAssertEqual(state.current, .collapsed)
    }

    // MARK: - expand()

    func test_expand_fromCollapsed_transitionsToExpanded() {
        var state = KeyboardState()
        state.expand()
        XCTAssertEqual(state.current, .expanded)
    }

    func test_expand_firesOnTransition_withExpanded() {
        var state = KeyboardState()
        var received: KeyboardState.Value?
        state.onTransition = { received = $0 }
        state.expand()
        XCTAssertEqual(received, .expanded)
    }

    func test_expand_fromExpanded_isNoOp_stateUnchanged() {
        var state = KeyboardState()
        state.expand() // collapse → expanded

        var transitionCount = 0
        state.onTransition = { _ in transitionCount += 1 }
        state.expand() // no-op

        XCTAssertEqual(state.current, .expanded)
        XCTAssertEqual(transitionCount, 0, "onTransition must not fire when already expanded")
    }

    // MARK: - collapse()

    func test_collapse_fromExpanded_transitionsToCollapsed() {
        var state = KeyboardState()
        state.expand()
        state.collapse()
        XCTAssertEqual(state.current, .collapsed)
    }

    func test_collapse_firesOnTransition_withCollapsed() {
        var state = KeyboardState()
        state.expand()

        var received: KeyboardState.Value?
        state.onTransition = { received = $0 }
        state.collapse()
        XCTAssertEqual(received, .collapsed)
    }

    func test_collapse_fromCollapsed_isNoOp_stateUnchanged() {
        var state = KeyboardState() // already collapsed

        var transitionCount = 0
        state.onTransition = { _ in transitionCount += 1 }
        state.collapse() // no-op

        XCTAssertEqual(state.current, .collapsed)
        XCTAssertEqual(transitionCount, 0, "onTransition must not fire when already collapsed")
    }
}
