import XCTest

/// Drives the real keyboard extension on a simulator.
///
/// Requires TinyKeyboard to be present in the simulator's keyboard list and the
/// software keyboard to be showing; `scripts/run-tests.sh` arranges both. When
/// the extension is not available the tests skip rather than fail, so a plain
/// `xcodebuild test` on a fresh simulator stays green.
final class SettingsPanelUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    /// Focuses the test field and cycles the system "Next keyboard" key until
    /// TinyKeyboard's panel is on screen. Skips if it never shows up.
    private func switchToTinyKeyboard() throws {
        let field = app.textFields["test-text-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        guard app.keyboards.firstMatch.waitForExistence(timeout: 5) else {
            throw XCTSkip("No software keyboard — hardware keyboard may be connected")
        }
        let collapse = app.buttons["tk-panel-collapse"]
        // iOS reopens the last-used keyboard, so TinyKeyboard may already be up
        // (still loading). Cycling away from it would defeat the test.
        _ = collapse.waitForExistence(timeout: 5)
        for _ in 0..<4 where !collapse.exists {
            // The switch key is labelled "Next keyboard", or after the keyboard it
            // would advance to ("Emoji") on current iOS releases.
            let next = app.buttons.matching(
                NSPredicate(format: "label IN %@", ["Next keyboard", "Next Keyboard", "Emoji", "Globe"])
            ).firstMatch
            guard next.waitForExistence(timeout: 2) else { break }
            next.tap()
            _ = collapse.waitForExistence(timeout: 8)
        }
        if !collapse.exists {
            throw XCTSkip("TinyKeyboard is not in the simulator's keyboard list")
        }
    }

    /// One test, one app launch: after the first launch on a simulator, XCUITest
    /// can reconnect the Mac's hardware keyboard, which hides the software
    /// keyboard for any later launch in the same boot.
    func testPanelShowsControlsThenCollapsesAwayOnDemand() throws {
        try switchToTinyKeyboard()
        for id in ["tk-panel-globe", "tk-panel-delete", "tk-panel-return", "tk-panel-dismiss", "tk-panel-collapse"] {
            XCTAssertTrue(app.buttons[id].exists, "\(id) should be on the panel")
        }

        // Third-party keyboards don't surface as `app.keyboards`; the panel itself is measurable.
        let panelHeight = app.otherElements["tk-panel"].frame.height
        XCTAssertEqual(panelHeight, 52, accuracy: 1, "expanded panel height")

        app.buttons["tk-panel-collapse"].tap()
        let gone = NSPredicate(format: "exists == false")
        expectation(for: gone, evaluatedWith: app.buttons["tk-panel-collapse"])
        waitForExpectations(timeout: 3)
        for id in ["tk-panel-globe", "tk-panel-delete", "tk-panel-return", "tk-panel-dismiss"] {
            XCTAssertFalse(app.buttons[id].exists, "\(id) should be gone once collapsed")
        }

        // Collapsed footprint: only the ~78pt system dock remains, so the page content
        // stays on screen and reachable above it.
        let screenHeight = app.frame.height
        let dockKey = app.buttons["Next keyboard"].firstMatch
        XCTAssertTrue(dockKey.waitForExistence(timeout: 3))
        XCTAssertGreaterThan(
            dockKey.frame.minY / screenHeight, 0.85,
            "Collapsed keyboard should leave everything above the system dock to the app")
        XCTAssertTrue(app.textFields["test-text-field"].isHittable)
        XCTAssertTrue(app.staticTexts["instructions-label"].isHittable)
    }
}
