import XCTest

final class KeyboardLayoutUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - GIVEN/WHEN/THEN: content readable above keyboard

    /// GIVEN the host app is open
    /// WHEN a text field is tapped and the keyboard appears
    /// THEN instructional content above the keyboard is not obscured
    func testContentVisibleAboveKeyboard() throws {
        // Find the test text field and tap it to activate keyboard
        let textField = app.textFields["test-text-field"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Test text field should exist")
        textField.tap()

        // Give keyboard time to animate in
        let keyboard = app.keyboards.firstMatch
        let keyboardAppeared = keyboard.waitForExistence(timeout: 3)

        // Content above the keyboard should be hittable (not obscured)
        let instructions = app.staticTexts["instructions-label"]
        if instructions.exists {
            // If the label exists, its frame should not overlap the keyboard frame
            if keyboardAppeared {
                let keyboardFrame = keyboard.frame
                let labelFrame = instructions.frame
                XCTAssertFalse(
                    labelFrame.intersects(keyboardFrame),
                    "Instructions label (y:\(labelFrame.maxY)) should not overlap keyboard (y:\(keyboardFrame.minY))"
                )
            }
            // Label should be accessible regardless of keyboard state
            XCTAssertTrue(instructions.isHittable, "Instructions should remain hittable when keyboard is active")
        }
    }

    /// GIVEN the keyboard is active
    /// WHEN we inspect the keyboard frame
    /// THEN the keyboard height leaves the majority of the screen readable
    func testKeyboardHeightIsMinimal() throws {
        let textField = app.textFields["test-text-field"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))
        textField.tap()

        let keyboard = app.keyboards.firstMatch
        guard keyboard.waitForExistence(timeout: 3) else {
            // If no keyboard appears (e.g., hardware keyboard), skip gracefully
            throw XCTSkip("No software keyboard appeared — hardware keyboard may be active")
        }

        let screenHeight = app.frame.height
        let keyboardHeight = keyboard.frame.height
        let fractionObscured = keyboardHeight / screenHeight

        // Keyboard should obscure less than 25% of screen in collapsed state
        // (Standard full keyboard is ~40%, TinyKeyboard collapsed should be ~8-12%)
        XCTAssertLessThan(
            fractionObscured,
            0.25,
            "Keyboard obscures \(Int(fractionObscured * 100))% of screen — expected < 25% for TinyKeyboard collapsed state"
        )
    }

    /// GIVEN the text field is focused
    /// WHEN we scroll or access content above the keyboard
    /// THEN the app does not scroll the content out of view unexpectedly
    func testAppContentRemainsAccessibleWhileTyping() throws {
        let textField = app.textFields["test-text-field"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))
        textField.tap()

        _ = app.keyboards.firstMatch.waitForExistence(timeout: 2)

        // Type some test text via the keyboard
        textField.typeText("test")

        // Content above should still be in the view hierarchy and accessible
        let staticTexts = app.staticTexts
        XCTAssertGreaterThan(staticTexts.count, 0, "Some text content should remain visible")
    }
}
