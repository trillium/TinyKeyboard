**ABANDONED 2026-07-02** — bubble workflow confirmed impossible; see BUBBLE_SPEC.md banner.

## Why

TinyKeyboard solves one problem: get a keyboard out of the way so voice-first users have full screen for dictation. But users occasionally need to type something — a name, a number, a correction — without leaving the keyboard. Right now their only option is the globe key, which switches away from TinyKeyboard entirely and abandons the minimal-footprint posture.

This change adds a second mode: a draggable composition bubble that appears on demand, lets the user compose text in a floating scratchpad, and injects the result directly into the focused field. The keyboard returns to invisible when done. The user never has to switch keyboards to type.

## What Changes

- The keyboard's `inputView` height changes from 1pt to 44pt with a transparent blur background — a touch-accessible hint bar that remains unobtrusive but signals interactivity
- Tapping the hint bar expands the keyboard to ~350pt, revealing a draggable composition bubble
- The bubble contains a text entry area and a send button; composing and submitting injects text via `UITextDocumentProxy.insertText()`
- The bubble position is draggable within the expanded frame and persists across keyboard appearances
- The keyboard collapses back to hint bar state after submission

## Capabilities

### New Capabilities

- `collapsed-hint-bar`: 44pt translucent blur bar with border; replaces the current 1pt height; tap expands to bubble mode
- `bubble-widget`: draggable floating composition widget inside the expanded inputView; text entry area, send button, drag handle, collapse affordance
- `text-injection`: submit triggers (send button, dwell timer, double-space) that call `insertText()` and clear the buffer

## Impact

- `TinyKeyboardExtension/KeyboardViewController.swift` — primary change file; height constraint, blur background, tap gesture, state machine, bubble view
- `TinyKeyboard/ContentView.swift` — update setup instructions to document bubble input mode
- New App Group entitlement required (both targets) for position persistence
- `TinyKeyboard.xcodeproj` — App Group capability added to both targets
