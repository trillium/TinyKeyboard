# TinyKeyboard

A near-invisible iOS keyboard extension. Designed for voice-first users who need to tap into input fields without losing screen real estate to a full keyboard.

Switch to TinyKeyboard, the input field activates, and you have your full screen back.

## What it does

- **1pt transparent keyboard** — effectively invisible
- **No keys** — no letters, no numbers, no suggestions bar
- **Globe key rotation** — the ~78pt system dock iOS renders beneath every keyboard extension (globe/mic/home-indicator) still lets you tap the globe to switch back to a real keyboard, regardless of the extension's own 1pt height; on devices where iOS also requires the extension to supply its own switching control, the extension adds a globe fallback button (calling `advanceToNextInputMode()`) to satisfy that API requirement — it's not a usable tap target on its own, since the system dock's globe is the actual switching affordance
- **Host app onboarding** — the app walks you through enabling the keyboard in Settings, links straight to Settings, and shows a live "enabled" status once iOS has loaded it
- **In-app privacy policy** — a Privacy Policy screen in the host app explains the keyboard collects and transmits nothing

## Why

iOS requires a keyboard to be active for text input fields to accept focus. If you use voice input (dictation, Siri, etc.), the standard keyboard wastes half your screen. TinyKeyboard gets out of the way.

## Install

Requires Xcode and an Apple Developer account (free works, but profiles expire after 7 days).

1. Open `TinyKeyboard.xcodeproj` in Xcode
2. Select your team in Signing & Capabilities for both targets (TinyKeyboard and TinyKeyboardExtension)
3. Connect your iPhone and select it as the run destination
4. Build & Run (Cmd+R)
5. On your iPhone: **Settings → General → Keyboard → Keyboards → Add New Keyboard → TinyKeyboard**
6. If prompted, trust the developer profile in **Settings → General → VPN & Device Management**

### CLI install

```bash
# Build
xcodebuild -project TinyKeyboard.xcodeproj -scheme TinyKeyboard \
  -destination 'platform=iOS,id=YOUR_DEVICE_ID' \
  -allowProvisioningUpdates build

# Install
xcrun devicectl device install app \
  --device YOUR_DEVICE_ID \
  path/to/Build/Products/Debug-iphoneos/TinyKeyboard.app
```

Find your device ID with `xcrun xctrace list devices`.

## Free account reprovisioning

With a free Apple Developer account, the provisioning profile expires every 7 days. The included `reinstall.sh` script rebuilds and reinstalls in one step. A LaunchAgent can automate this weekly.

## License

MIT
