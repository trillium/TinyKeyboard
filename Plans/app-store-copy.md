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

Device: iPhone 16 Pro Max (6.9"), required App Store screenshot group — 1320×2868px portrait.

1. **Before**: A messaging or notes app with the standard iOS keyboard open, covering roughly half the screen, text field visible near the top edge of the keyboard.
2. **After**: The same app/text field with TinyKeyboard active — full screen visible, text field focused (cursor blinking), no on-screen keyboard chrome. Caption: "Your screen stays yours."
3. **Host app onboarding screen**: showing the setup instructions and "Open App Settings" button, to make the setup flow legible to reviewers and prospective users.
4. Optional: a shot of Settings → Keyboards showing TinyKeyboard listed alongside the default keyboard, to illustrate the enable step.

Capture with the iOS Simulator (`xcrun simctl io booted screenshot`) — no paid Apple Developer enrollment required. Capturing on a physical device instead requires a paid Apple Developer Program enrollment (for on-device installation/archiving) and the corresponding device/archive setup.

## Pricing
Free (no in-app purchases, no data collection — see privacy policy).

## Category
Utilities

## Age rating
4+ (no objectionable content, no user-generated content, no data collection)
