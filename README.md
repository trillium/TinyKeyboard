# TinyKeyboard

A near-invisible iOS keyboard extension. Designed for voice-first users who need to tap into input fields without losing screen real estate to a full keyboard.

Switch to TinyKeyboard, the input field activates, and you have your full screen back.

## What it does

- **1pt transparent keyboard** — effectively invisible
- **Settings panel** — a small 52pt control strip appears once when you rotate into the keyboard; its collapse button returns the keyboard to 1pt
- **No keys** — no letters, no numbers, no suggestions bar
- **Globe key rotation** — the ~78pt system dock iOS renders beneath every keyboard extension (globe/mic/home-indicator) still lets you tap the globe to switch back to a real keyboard, regardless of the extension's own 1pt height; on devices where iOS also requires the extension to supply its own switching control, the extension adds a globe fallback button (calling `advanceToNextInputMode()`) to satisfy that API requirement — it's not a usable tap target on its own, since the system dock's globe is the actual switching affordance
- **Host app onboarding** — the app walks you through enabling the keyboard in Settings, links straight to Settings, and shows a live "enabled" status once iOS has loaded it
- **In-app privacy policy** — a Privacy Policy screen in the host app explains the keyboard collects and transmits nothing

## Why

iOS requires a keyboard to be active for text input fields to accept focus. If you use voice input (dictation, Siri, etc.), the standard keyboard wastes half your screen. TinyKeyboard gets out of the way.

## Install

The only supported way to put TinyKeyboard on an iPhone is over the air, over Tailscale. There is no USB, Xcode Run or home-Wi-Fi install path.

```bash
scripts/run-tests.sh   # gate: must pass before publishing
./ota-publish.sh       # ad-hoc build + manifest + install page into ~/ota
```

`ota-publish.sh` writes the `.ipa`, `manifest.plist` and `index.html` into `~/ota` (override with `OTA_DIR`). They are served tailnet-only on port 8784 with `tailscale serve --https=8784` (never Funnel, never the `:443` root or `:8443`); the one-time setup is in **`AGENTS.md`**, "OTA install over Tailscale".

Then, on the iPhone with the Tailscale app connected, open the printed `https://<mac>.<tailnet>.ts.net:8784/` page in **Safari** and tap Install.

Requires a **paid** Apple Developer Program membership on team `TV2582LRYN` (ad-hoc profiles last about a year) and the iPhone registered for that team.

After installing, enable the keyboard on the iPhone: **Settings → General → Keyboard → Keyboards → Add New Keyboard → TinyKeyboard**. If prompted, trust the developer profile in **Settings → General → VPN & Device Management**.

## License

MIT
