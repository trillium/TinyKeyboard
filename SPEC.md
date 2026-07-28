# TinyKeyboard — Spec

> Canonical product spec. Restored 2026-07-02 after the bubble-input detour was
> confirmed defunct (see BUBBLE_SPEC.md banner and Non-goals below).

## Purpose
A custom iOS keyboard extension with near-zero visual height. Designed for
voice-first users who need to tap into input fields without losing screen
real estate to a full keyboard. Switch to TinyKeyboard, the input field
activates, and you have your full screen back.

## Requirements
- **Minimal height**: 1px (1pt) — fully invisible. The pre-bubble
  implementation was a 1pt transparent keyboard with no visible UI (see
  README.md); that is the target.
- **No keys**: No letter keys, no number keys, no suggestions bar
- **No bubble/expanded mode**: The keyboard has exactly one state — invisible
- **No settings panel** beyond whatever App Store review demands
- **Target device**: iPhone (iOS 17+)
- **App Store submission is the goal** — active plan at
  `Plans/app-store-readiness.md`

## Architecture
- Host app: Minimal container app (required by iOS for extensions)
- Keyboard extension: `UIInputViewController` subclass
  - Constrain `inputView` height to 1pt
  - Transparent background, no visible UI

## Non-goals
- Speech recognition
- Any actual key input
- iPad optimization
- Bubble/expanded composition mode — explored and rejected 2026-07-02
  (defunct, see BUBBLE_SPEC.md banner)

## Open questions
- **Keyboard switching affordance (globe)**: resolved 2026-07-28 —
  `KeyboardViewController` checks `needsInputModeSwitchKey` and adds its own
  globe fallback button (calling `advanceToNextInputMode()`) to satisfy the
  API requirement. That button is nested inside the 1pt-tall extension input
  view, so its own tap target is far below Apple's 44×44pt guidance — it is
  not the practical switching affordance. The actual usable control is the
  ~78pt system dock (globe/mic/home-indicator) that iOS renders beneath every
  keyboard extension regardless of the extension's own view height; that
  system-owned control is what users tap to switch keyboards.
