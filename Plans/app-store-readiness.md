# Tiny Keyboard — App Store Readiness

## Problem

Alpha exists. Tiny Keyboard needs to be hardened and polished to be ready for the Apple App Store. Additionally, Trillium doesn't have a working Swift test setup and needs help establishing one.

## What Tiny Keyboard Is

An on-screen keyboard that is at most 1 pixel tall — invisible to voice users. The point: voice users who fill inputs via commands (Talon Voice, Dragon, etc.) are constantly interrupted by the standard iOS keyboard taking up screen space. TinyKeyboard solves this by being there when the system needs a keyboard but getting completely out of the way visually.

Alpha is already out.

## Next Steps

### 1. Robustness Pass

Harden the alpha. Fix any crashes or edge cases found during testing. Make it reliable across iOS versions and device sizes.

### 2. Swift Testing Setup

Trillium does not currently know how to write Swift tests. Need:

- XCTest setup for unit tests
- UI testing with XCUITest for interaction validation
- Guidance on what to test in a keyboard extension specifically

### 3. App Store Submission

Prepare for App Store review:

- In-app Privacy Policy screen added (`PrivacyPolicyView` in `TinyKeyboard/ContentView.swift`) — done 2026-07-28, but this is the in-app screen only. A static, publicly-hostable counterpart (`privacy-policy.html`) was added 2026-08-01 but is not yet hosted anywhere. Still open: publish it at a public URL and add that URL to App Store Connect metadata (required for submission; the in-app screen alone does not satisfy this).
- ~~Globe key / `needsInputModeSwitchKey` compliance~~ — done 2026-07-28: `KeyboardViewController` adds a fallback globe button when the system requires one
- App Store screenshots and description — drafted in `Plans/app-store-copy.md`; screenshots still need to be captured
- App icon — not yet produced; see `Plans/app-icon-spec.md`
- Reviewer note: the keyboard looks invisible by design — explain the use case (drafted in `Plans/app-store-copy.md`'s App Review Note)
- Entitlements and capabilities review

### 4. Settings Panel (UX Design)

The keyboard needs some controls without violating the minimalist contract. Current design concept:

- Rotating into TinyKeyboard from another keyboard brings up a small settings/control panel
- Panel shows: app controls + a collapse button
- Collapsing hides the panel until the keyboard is reloaded
- Panel must not increase the keyboard's footprint while collapsed

### 5. Local Inference (Exploratory)

Potential integration with WhisperFlow for on-device speech recognition. Not committed yet. Consider after App Store submission is complete.

## Open Questions for Architecture Pass

- What does the keyboard extension entitlement require for App Store review?
- Is XCUITest the right tool for testing keyboard extension UI, or are there limitations?
- How does the settings panel interact with the keyboard extension lifecycle?
- What's the right way to test the 1px height across all iPhone screen sizes?

## Repo

`~/code/TinyKeyboard/`

## Decisions

- **2026-07-02**: Bubble input mode confirmed defunct — a keyboard extension cannot receive text into its own views (no second keyboard or system dictation available inside an extension). Target reverted to the original 1px invisible keyboard (SPEC.md is canonical again; see BUBBLE_SPEC.md banner). The Robustness Pass (§1) now includes reverting the bubble code in `TinyKeyboardExtension/` back to the 1px implementation.
- **2026-07-28**: App Store submission prep (§3) landed: `needsInputModeSwitchKey` globe fallback, host app onboarding with a live keyboard-enabled status badge, an in-app Privacy Policy screen, and drafts of the App Store copy and app icon spec (`Plans/app-store-copy.md`, `Plans/app-icon-spec.md`). Still outstanding: producing the actual app icon PNG and capturing screenshots.
- **2026-08-01**: Reconciliation pass — the beads tracker (`TinyKeyboard-2h0.2`, `.3`, `.4`, `.6`) still showed these as open even though the 2026-07-28 work closed them in practice; the Dolt server backing this repo's beads store was unreachable from this session's environment (`bd`/`beads` federation and direct connect both failed — see PR description), so the tracker itself couldn't be updated here and needs reconciliation from a machine with Dolt access. Added `privacy-policy.html` (static, unhosted) so the in-app privacy screen's text has a public-URL-ready counterpart for App Store Connect metadata — it still needs to be published somewhere publicly reachable (e.g. GitHub Pages; the existing Tailscale OTA host does not qualify, since `tailscale serve` only publishes to the tailnet — see `AGENTS.md`'s OTA section) and that URL added to App Store Connect; enabling GitHub Pages is a repo-settings change this session did not make unilaterally. Still outstanding, unchanged: app icon PNG, real device/simulator screenshots, and paid Apple Developer Program enrollment (`TinyKeyboard-2h0.1`).
