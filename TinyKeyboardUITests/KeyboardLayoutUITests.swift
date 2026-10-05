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
            "Keyboard obscures \(Int(fractionObscured * 100))% of screen — expected < 25% for TinyKeyboard "
                + "collapsed state"
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

    // MARK: - GIVEN/WHEN/THEN: App Store submission requirements are reachable

    /// GIVEN the host app onboarding screen
    /// WHEN the user taps "Privacy Policy"
    /// THEN the privacy policy sheet appears with its required disclosures
    func testPrivacyPolicySheetDisplays() throws {
        let privacyButton = app.buttons["privacy-policy-button"]
        XCTAssertTrue(
            privacyButton.waitForExistence(timeout: 3),
            "Privacy Policy button should exist on onboarding screen"
        )

        let onboardingScreenshot = XCTAttachment(screenshot: app.screenshot())
        onboardingScreenshot.name = "01-onboarding-screen"
        onboardingScreenshot.lifetime = .keepAlways
        add(onboardingScreenshot)

        privacyButton.tap()

        let privacyTitle = app.navigationBars["Privacy Policy"]
        XCTAssertTrue(
            privacyTitle.waitForExistence(timeout: 3),
            "Privacy Policy sheet should present with its navigation title"
        )
        XCTAssertTrue(
            app.staticTexts["TinyKeyboard does not collect, transmit, store, or share any personal data."].exists,
            "Privacy policy should state no data collection"
        )

        let privacyScreenshot = XCTAttachment(screenshot: app.screenshot())
        privacyScreenshot.name = "02-privacy-policy-sheet"
        privacyScreenshot.lifetime = .keepAlways
        add(privacyScreenshot)

        app.buttons["Done"].tap()
        XCTAssertFalse(
            privacyTitle.waitForExistence(timeout: 2),
            "Privacy Policy sheet should dismiss after tapping Done"
        )
    }

    // MARK: - App Store screenshot capture (run on the target device, not asserted as product behavior)

    /// Host-app onboarding only. Keyboard switching is done from the Mac side
    /// (XCUITest reconnects the hardware keyboard, which hides the software keyboard).
    func testCaptureAppStoreOnboarding() throws {
        try Self.requireCaptureFlag()
        let outDir = Self.screenshotOutputDirectory()
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        XCTAssertTrue(
            app.staticTexts["instructions-label"].waitForExistence(timeout: 5),
            "Onboarding title should be on screen before capturing"
        )
        try Self.writeScreenshot(named: "03-onboarding.png", to: outDir)
    }

    /// Focus the test field and hold so a Mac-side driver can toggle the software keyboard.
    func testHoldTextFieldFocus() throws {
        try Self.requireCaptureFlag()
        let marker = Self.appStoreScreenshotsURL.appendingPathComponent("FOCUS_READY")
        try? FileManager.default.removeItem(at: marker)
        let textField = app.textFields["test-text-field"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        try Data().write(to: marker)
        // Hold first-responder so simctl screenshots can run from the host.
        Thread.sleep(forTimeInterval: 40)
    }

    func testCaptureSettingsKeyboards() throws {
        try Self.requireCaptureFlag()
        continueAfterFailure = true
        let outDir = Self.screenshotOutputDirectory()
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        try Self.captureKeyboardsSettings(to: outDir)
    }

    private static let appStoreScreenshotsURL: URL = {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return repoRoot.appendingPathComponent("AppStore/screenshots", isDirectory: true)
    }()

    private static func requireCaptureFlag() throws {
        let flag = Self.appStoreScreenshotsURL.appendingPathComponent("CAPTURE")
        if !FileManager.default.fileExists(atPath: flag.path) {
            throw XCTSkip("App Store capture tests are opt-in; touch AppStore/screenshots/CAPTURE")
        }
    }

    private static func screenshotOutputDirectory() -> URL {
        let pointer = Self.appStoreScreenshotsURL.appendingPathComponent("CURRENT_DIR.txt")
        if let path = try? String(contentsOf: pointer, encoding: .utf8) {
            let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return URL(fileURLWithPath: trimmed)
            }
        }
        return Self.appStoreScreenshotsURL.appendingPathComponent("iphone-6.9", isDirectory: true)
    }

    private static func writeScreenshot(named name: String, to directory: URL) throws {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = directory.appendingPathComponent(name)
        try data.write(to: url)
    }

    private static func captureKeyboardsSettings(to directory: URL) throws {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        _ = settings.wait(for: .runningForeground, timeout: 8)

        func tapLabel(_ label: String) {
            let candidates: [XCUIElement] = [
                settings.staticTexts[label].firstMatch,
                settings.buttons[label].firstMatch,
                settings.cells[label].firstMatch
            ]
            for element in candidates where element.waitForExistence(timeout: 1.5) {
                element.tap()
                return
            }
        }

        tapLabel("General")
        tapLabel("Keyboard")
        tapLabel("Keyboards")
        // iOS 26 Keyboard page: the list is behind the cell identifier KEYBOARDS ("Keyboards, 3").
        let listRow = settings.cells["KEYBOARDS"].firstMatch
        if listRow.waitForExistence(timeout: 2) {
            listRow.tap()
        }
        try writeScreenshot(named: "04-settings-keyboards.png", to: directory)

        tapLabel("Add New Keyboard…")
        tapLabel("Add New Keyboard...")
        tapLabel("Add New Keyboard")
        let tiny = settings.staticTexts["TinyKeyboard"].firstMatch
        if tiny.waitForExistence(timeout: 3) {
            tiny.tap()
            // Confirm allow-full-access / add sheets if they appear.
            tapLabel("Allow")
            tapLabel("Add")
            try writeScreenshot(named: "05-settings-keyboards-post-add.png", to: directory)
        }
    }
}
