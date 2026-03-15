# TinyKeyboard — Spec

## Purpose
A custom iOS keyboard extension with near-zero visual height. Designed for
voice-first users who need to tap into input fields without losing screen
real estate to a full keyboard. Switch to TinyKeyboard, the input field
activates, and you have your full screen back.

## Requirements
- **Single UI element**: Globe button (required by iOS for keyboard switching)
- **Minimal height**: ~30pt or less — just enough to hold the globe icon
- **No keys**: No letter keys, no number keys, no suggestions bar
- **Local install only**: Sideloaded via Xcode, no App Store submission
- **Target device**: iPhone (iOS 17+)

## Architecture
- Host app: Minimal container app (required by iOS for extensions)
- Keyboard extension: `UIInputViewController` subclass
  - Override `viewDidLoad` to set up globe button
  - Constrain `inputView` height to ~30pt
  - Style: dark/translucent bar with centered globe icon

## Non-goals
- Speech recognition
- Any actual key input
- App Store release
- iPad optimization
