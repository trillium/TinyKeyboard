# TinyKeyboard 1.0 — App Store submission package

Paste-ready metadata for App Store Connect. Prepared 2026-10-16 on `fm/tinykeyboard-appstore-20261017`.
Nothing here has been uploaded or submitted. Captain steps: `CAPTAIN_CHECKLIST.md`. Dated plan: `PLAN_TO_2026-10-20.md`.

## App record

| Field | Value |
| --- | --- |
| Name | TinyKeyboard |
| Subtitle (30 max) | Voice-first invisible keyboard |
| Bundle ID | `com.trillium.TinyKeyboard` (extension: `com.trillium.TinyKeyboard.keyboard`) |
| SKU | `tinykeyboard-ios` (any unique string; not shown to users) |
| Primary language | English (U.S.) |
| Platform | iOS, iPhone only (`TARGETED_DEVICE_FAMILY = 1`; no iPad build, no iPad screenshots) |
| Minimum iOS | 17.0 |
| Version / build | 1.0 (1) |
| Category | Utilities (secondary: Productivity) |
| Price | Free, no in-app purchases |
| Age rating | 4+ (answer "None" to every content question) |
| Copyright | 2026 Trillium Smith |

## Description (4000 max)

```
TinyKeyboard is a keyboard with one job: get out of your way.

If you control your iPhone by voice (Talon Voice, Dragon, iOS Voice Control, dictation), every tap on a text field raises a keyboard that covers half your screen. TinyKeyboard is 1 point tall. It keeps text fields focused and ready for voice input, and your whole screen stays yours.

HOW TO USE
1. Install TinyKeyboard.
2. Open Settings > General > Keyboard > Keyboards > Add New Keyboard > TinyKeyboard.
3. Tap any text field, then switch to TinyKeyboard with the globe key.
4. Speak. Your full screen is visible.

A SMALL CONTROL STRIP, ONLY WHEN YOU WANT IT
When you switch into TinyKeyboard, a thin strip appears with Next keyboard, Delete, Return and Hide keyboard buttons, plus a collapse button. Tap collapse and the keyboard returns to 1 point. Switch away and back to see the strip again.

PRIVATE BY DESIGN
TinyKeyboard does not ask for Full Access, has no network access, collects nothing and stores nothing. It cannot read what you type.

Switch back to your regular keyboard at any time with the globe key.

TinyKeyboard has no keys by design. It is intended for voice-first users.
```

## Promotional text (170 max)

`Your screen stays yours. A 1-point keyboard that keeps text fields ready for voice input.`

## Keywords (100 chars max, comma-separated, no spaces after commas)

```
voice,keyboard,invisible,dictation,voice control,accessibility,hands free,talon,dragon,tiny
```

(91 chars. "TinyKeyboard", "keyboard extension" and the category name are already indexed, so they are left out.)

## URLs

| Field | Value |
| --- | --- |
| Privacy Policy URL | https://trillium.github.io/TinyKeyboard/privacy-policy.html |
| Support URL | https://github.com/trillium/TinyKeyboard (captain: swap for a dedicated page if preferred) |
| Marketing URL | leave blank |

## App Privacy answers (App Store Connect > App Privacy)

| Question | Answer | Why it is true |
| --- | --- | --- |
| Do you or your third-party partners collect data from this app? | **No, we do not collect data from this app** | Result label: "Data Not Collected". No analytics SDK, no network calls, empty entitlements for both targets. |
| Tracking | No | Nothing is collected, so nothing is linked or shared. |
| Keyboard extension | `RequestsOpenAccess = false` | No Full Access prompt; the extension is sandboxed with no network and cannot share data with the app. A unit test (`ExtensionManifestTests`) fails the build if this flips. |
| Export compliance (encryption) | Not using non-exempt encryption | `ITSAppUsesNonExemptEncryption = NO` is set in the app's Info.plist, so the question is not asked on each upload. |
| Content rights | Does not contain third-party content | |
| Advertising identifier (IDFA) | No | |
| Sign-in required | No | No demo account needed. |

The extension reads nothing from the focused text field. It only calls `deleteBackward()`, `insertText("\n")` and `dismissKeyboard()` when the user taps the matching panel button.

## Screenshots (iPhone 6.9", 1320x2868, upload all four; 3 to 10 allowed)

Files in `AppStore/screenshots/iphone-6.9/`:

1. `01-before-system-keyboard.png` — standard keyboard covering half the screen.
2. `02-after-tinykeyboard.png` — same field with TinyKeyboard; full screen visible.
3. `03-onboarding.png` — setup steps and "Open App Settings".
4. `04-settings-keyboards.png` — TinyKeyboard in Settings > Keyboards.

No iPad set is needed: the binary is iPhone-only. The old `AppStore/screenshots/ipad-13/` files are unused and can stay in the repo.

Optional, not blocking: shots 1 to 4 were captured 2026-09-06, before the control strip existed. Shot 2 shows TinyKeyboard with only the system dock. If time allows, add a fifth shot of the expanded strip (simulator, iPhone 17 Pro Max, TinyKeyboard active, strip showing). Tracked as a bead.

## Review notes (paste into "App Review Information > Notes")

```
TinyKeyboard is an intentionally near-invisible keyboard for people who control their iPhone by voice (Talon Voice, Dragon, iOS Voice Control). These users need a keyboard active so text fields accept focus and dictation, but the standard keyboard covers half the screen. The blank keyboard is the feature, not a bug.

HOW TO TEST (2 minutes)
1. Settings > General > Keyboard > Keyboards > Add New Keyboard > TinyKeyboard. Do NOT enable Full Access; the keyboard does not request it (RequestsOpenAccess = false).
2. Open any app with a text field (Notes, Messages, or the TinyKeyboard app's own test field). Tap the field.
3. Press and hold the globe key (bottom left, in the system dock) and choose TinyKeyboard, or tap the globe until it appears.
4. A thin control strip (52 pt) appears with five buttons: Next keyboard, Delete, Return, Hide keyboard, Collapse. Tap Collapse. The strip disappears and the keyboard is 1 pt tall. Only the iOS system dock (globe and microphone) remains under the text field.
5. Tap the system globe in the dock to return to your normal keyboard at any time. Tap the microphone to dictate into the field.

WHY THERE IS NOTHING TO SEE
When collapsed the keyboard's view is 1 pt tall and transparent. iOS itself draws the globe/microphone dock beneath every keyboard extension; that dock is the switching control. On devices where iOS requires the extension to supply its own switching control (needsInputModeSwitchKey), the extension adds a fallback button that calls handleInputModeList(from:with:).

PRIVACY
No Full Access, no network, no data collected or stored, empty entitlements. The extension never reads text from the field. Privacy policy: https://trillium.github.io/TinyKeyboard/privacy-policy.html

Secure (password) fields: iOS replaces all third-party keyboards there. This is system behavior.

The companion app only shows setup instructions, a status badge and a button that opens Settings. No sign-in is needed.
```

Contact info for the review form (first name, last name, phone, email) is a captain entry; see the checklist.

## Open risk: does the strip come back after a switch?

The strip shows once per `KeyboardViewController` load and stays collapsed until iOS creates a new controller (`PanelState`). iOS normally creates a fresh controller each time the user switches into a keyboard extension, but this was verified only on the simulator, not on a device or across iOS versions. If a device reuses the controller, "switch away and back to see the strip again" (description, review notes, `TESTING.md` step 4) would be wrong and the user would have no way to reopen the strip.

Before submitting: run the manual real-iPhone checklist in `TESTING.md`. If the strip does not return, either reword the description/notes to say "force-quit and reopen the app" or add a reopen trigger (for example `viewWillAppear`) as a 1.0.1 change. Reviewers are unlikely to hit this, because the review note only requires the strip to appear once.

## Known limits (not blockers)

- The ~78pt system dock under the keyboard cannot be removed by any extension. "Invisible" means the extension adds 1 pt, not zero pixels.
- The host app badge reads "Not detected yet" until iOS reports TinyKeyboard as an active input mode. It never claims the keyboard is off.
- The archive built on 2026-10-16 is development-signed (see `CAPTAIN_CHECKLIST.md`, step 6). Re-export it with App Store signing before uploading.
