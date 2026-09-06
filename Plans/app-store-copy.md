# TinyKeyboard — App Store Copy

## Name
TinyKeyboard

## Subtitle
Voice-first invisible keyboard

## Description

TinyKeyboard is a keyboard extension with a single purpose: get out of your way.

If you use voice input — Talon Voice, Dragon, iOS dictation, or any other voice control — you know the frustration: every time you tap a text field, the iOS keyboard slides up and takes half your screen.

TinyKeyboard is 1 point tall. Invisible. It keeps text fields focused and ready for voice input without stealing your screen.

How to use:
1. Install TinyKeyboard from the App Store
2. Add it in Settings → General → Keyboard → Keyboards
3. Tap any text field and switch to TinyKeyboard
4. Speak normally — your full screen is yours

Switch back to your regular keyboard anytime using the globe key.

Note: This keyboard has no keys by design. It is intended for voice-first users only.

## Keywords
voice keyboard, invisible keyboard, dictation, voice control, accessibility, keyboard extension

## App Review Note

This keyboard extension is intentionally blank. It is designed for users who control their iPhone entirely by voice (Talon Voice, Dragon Professional, iOS Voice Control, etc.). These users need a keyboard active so text fields accept focus, but the standard iOS keyboard wastes half the screen.

TinyKeyboard is 1 point tall and fully transparent. Keyboard switching is provided by the iOS system globe key, which iOS renders in its own system dock beneath every keyboard extension regardless of the extension's own view height; on devices where iOS also requires the extension to supply its own switching control (`needsInputModeSwitchKey`), the extension additionally includes a 1pt-tall fallback button that calls `advanceToNextInputMode()`. The host app provides setup instructions and a link to the app's Settings page.

To test: add TinyKeyboard in Settings → General → Keyboard → Keyboards, then tap any text field and switch to TinyKeyboard using the globe key. The keyboard will be invisible — this is the intended behavior.

## Screenshots needed

Captured 2026-09-06 — see `AppStore/README.md`.

**iPhone 6.9"** (required) — 1320×2868px portrait, iPhone 16 Pro Max simulator, in `AppStore/screenshots/iphone-6.9/`.

1. **Before**: host app with the standard iOS keyboard open, covering roughly half the screen.
2. **After**: the same text field with TinyKeyboard active — full screen visible, cursor blinking, only the system globe/mic dock. (Copy caption if you add marketing frames later: "Your screen stays yours.")
3. **Host app onboarding screen**: setup instructions and "Open App Settings".
4. **Settings → Keyboards**: TinyKeyboard listed alongside English (US) and Emoji.

**iPad 13"** (required while the app runs on iPad) — 2064×2752px portrait, iPad Pro 13-inch (M5) simulator, in `AppStore/screenshots/ipad-13/`. Same four states.

Raw simulator PNGs, RGB, no alpha. App Store Connect accepts these without device frames.

## Pricing
Free (no in-app purchases, no data collection — see privacy policy).

## Category
Utilities

## Age rating
4+ (no objectionable content, no user-generated content, no data collection)
