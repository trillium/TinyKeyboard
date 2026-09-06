# App Store assets

Captured 2026-09-06 on the iOS 26.2 simulator. All PNGs are RGB (no alpha), matching App Store Connect's "no transparency" rule.

## iPhone 6.9" (required) — 1320×2868

Device: iPhone 16 Pro Max simulator.

| File | Shot |
| --- | --- |
| `screenshots/iphone-6.9/01-before-system-keyboard.png` | Host app, test field focused, standard iOS keyboard covering ~half the screen |
| `screenshots/iphone-6.9/02-after-tinykeyboard.png` | Same field focused (cursor), TinyKeyboard active — only the system globe/mic dock |
| `screenshots/iphone-6.9/03-onboarding.png` | Host app onboarding (setup steps + Open App Settings) |
| `screenshots/iphone-6.9/04-settings-keyboards.png` | Settings → Keyboards list with TinyKeyboard enabled |

## iPad 13" (required while `TARGETED_DEVICE_FAMILY = 1,2`) — 2064×2752

Device: iPad Pro 13-inch (M5) simulator.

| File | Shot |
| --- | --- |
| `screenshots/ipad-13/01-before-system-keyboard.png` | Host app, standard iPad keyboard |
| `screenshots/ipad-13/02-after-tinykeyboard.png` | Same field focused, TinyKeyboard active (no keyboard chrome) |
| `screenshots/ipad-13/03-onboarding.png` | Host app onboarding |
| `screenshots/ipad-13/04-settings-keyboards.png` | Settings → Keyboards with TinyKeyboard listed |

`SPEC.md` still lists iPad as a non-goal. The binary currently ships for iPhone and iPad, so App Store Connect will require the 13" set unless device family is changed to iPhone-only.

## Recapture

Opt-in UI tests in `TinyKeyboardUITests` (skipped unless `AppStore/screenshots/CAPTURE` exists):

1. `touch AppStore/screenshots/CAPTURE`
2. Write the output dir into `AppStore/screenshots/CURRENT_DIR.txt`
3. `xcodebuild test -only-testing:TinyKeyboardUITests/KeyboardLayoutUITests/testCaptureSettingsKeyboards`
4. For keyboard states: run `testHoldTextFieldFocus`, then Simulator **I/O → Keyboard → Toggle Software Keyboard**, then `xcrun simctl io <udid> screenshot`

XCUITest reconnects the hardware keyboard, which is why the software keyboard is toggled from the Mac side rather than inside the test.
