# Testing TinyKeyboard

Run everything: `scripts/run-tests.sh` (about two minutes). Unit tests only: `scripts/run-tests.sh unit`.
Another device size: `SIM_NAME="iPhone 16e" scripts/run-tests.sh`.

Needs Xcode 26 and an installed iOS simulator. No signing, no device.

## The three layers

| Layer | Target | What it proves |
| --- | --- | --- |
| Unit (XCTest) | `TinyKeyboardTests` | The footprint contract (`PanelState`), the real extension Auto Layout resolves to exactly 1pt collapsed / 52pt expanded at ten widths (320–932pt, portrait and landscape), panel buttons are ≥44pt and labelled, and the extension's `Info.plist` still says keyboard-service with `RequestsOpenAccess = false`. |
| UI, host app (XCUITest) | `TinyKeyboardUITests/KeyboardLayoutUITests` | Onboarding screen, Privacy Policy sheet, text field accepts input. |
| UI, real extension (XCUITest) | `TinyKeyboardUITests/SettingsPanelUITests` | Switch to TinyKeyboard with the system globe key, panel controls appear, collapse removes them and leaves only the system dock. |

## How a keyboard extension is tested

- **You cannot `import` an extension.** `TinyKeyboardTests` compiles `KeyboardViewController.swift`, `PanelState.swift` and `SettingsPanelView.swift` directly into the test bundle, and the bundle is hosted in the app. Add a new extension source file to both targets.
- **Put logic in plain types** (`PanelState`) so it needs no UIKit, and keep the controller thin.
- **Test layout by hosting `controller.inputView`** in a container of a given width, calling `layoutIfNeeded()`, and reading its frame. That is the 1px check, run at every width.
- **The `Info.plist` test is a submission guard.** The privacy answers claim no Full Access; a stray `RequestsOpenAccess = true` fails the build.
- **XCUITest cannot see third-party keyboards as `app.keyboards`.** The extension's views show up as ordinary `app.buttons[...]` elements, so every panel control has an `accessibilityIdentifier` (`tk-panel-*`). The panel is measured via `app.otherElements["tk-panel"]`.

## UI test limits

- `scripts/run-tests.sh` enables TinyKeyboard in the simulator by writing `AppleKeyboards`, then reboots the simulator. Without that step `SettingsPanelUITests` skips (it does not fail).
- After the first app launch on a booted simulator, XCUITest can connect the Mac's hardware keyboard, which hides the software keyboard. That is why the extension flow is one test method and the script reboots first.
- Opt-in App Store screenshot capture tests in `KeyboardLayoutUITests` are skipped unless `AppStore/screenshots/CAPTURE` exists (see `AppStore/README.md`).

## Not covered by automation: check on a real iPhone before submitting

1. Install the build, add TinyKeyboard in Settings → General → Keyboard → Keyboards.
2. Focus a text field, switch to TinyKeyboard with the globe. The panel should appear above the system dock.
3. Tap Delete / Return / Hide keyboard / globe, then Collapse. Only the system dock should remain.
4. Switch away and back. The panel should return (iOS normally creates a fresh controller on each switch; if it does not on some iOS version, see "Open risk" in `Plans/submission/SUBMISSION_PACKAGE.md`).
5. Check a secure (password) field: iOS replaces third-party keyboards there, which is expected.
