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

On the captain's iPhone the install is automatic, over Tailscale: no link, no tap.

```bash
make ship-gate        # proves HEAD (tests green, tree clean); never touches the phone
make stable-install   # reaches the phone with phone-reach, builds, installs with devicectl
```

`make stable-install` refuses without a ship-gate pass for HEAD and runs under `scripts/phone-session.sh` (phone lock, then `phone-reach`), so it works on whatever network the phone is on. Requires the iPhone registered for team `TV2582LRYN`.

`./ota-publish.sh` is a non-captain fallback that publishes an OTA install page for someone else to open; it is not how the captain's phone is installed (`AGENTS.md`, "OTA pages: non-captain fallback").

After installing, enable the keyboard on the iPhone: **Settings → General → Keyboard → Keyboards → Add New Keyboard → TinyKeyboard**. If prompted, trust the developer profile in **Settings → General → VPN & Device Management**.

## License

MIT
