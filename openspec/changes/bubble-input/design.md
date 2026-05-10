## Context

TinyKeyboard is a `UIInputViewController` that sets `inputView` height to 1pt with a clear background. The only prior design goal was invisibility. The system dock bar (~78pt) is always rendered below the extension by iOS and cannot be controlled — so "invisible" has always meant "near-invisible."

This change adds a second mode on top of the existing behavior. The collapsed state (hint bar) replaces the current 1pt design. The expanded state (bubble) is new. Both states live inside the same `inputView` — no new targets, no new processes, no cross-process communication required.

The iPad floating keyboard is the direct conceptual precedent. No iOS third-party keyboard currently offers a draggable floating input on iPhone.

## Goals / Non-Goals

**Goals:**
- Collapsed hint bar that is touch-accessible, visually present but non-obtrusive
- Expanded bubble widget that is draggable within the inputView frame
- Text injection via `UITextDocumentProxy.insertText()` on submission
- Position persistence across keyboard appearances via App Group UserDefaults
- Clean animated transition between states
- Accessibility: tap affordance (no gesture-only paths)

**Non-Goals:**
- Full-screen widget placement — `inputView` is anchored to the bottom; drag area is limited to ~350pt from the bottom edge
- Suppressing the system dock bar (~78pt) — this is outside the extension's view hierarchy
- Shake-to-reveal — keyboard extensions cannot receive motion events from the host app's responder chain
- Autocomplete, spell-check, or predictive text
- iPad layout

## Decisions

### D1: 44pt height for collapsed state, not 1pt

The current 1pt height has a 1pt touch target — effectively untappable. The hint bar needs a minimum 44pt touch target (Apple HIG minimum). The visual appearance can still read as a thin sliver by using a transparent blur with only the bottom 1–2pt showing a visible edge, but the touch frame is 44pt.

**Alternative considered:** Keep 1pt and use a separate gesture (e.g., long press on the system dock bar). Rejected — the system dock bar is outside the extension's view hierarchy; it cannot receive gestures from the extension.

### D2: `systemUltraThinMaterial` blur for both states

`UIBlurEffect(style: .systemUltraThinMaterial)` adapts to light/dark mode automatically, reads as interactive chrome (users recognize it from Control Center and sheets), and lets app content show through — the core non-obstructive requirement. Paired with a 1pt border at 50% opacity to give a defined edge.

**Alternative considered:** Solid color at 20% opacity. Rejected — color value needs to work on both light and dark backgrounds; adaptive blur handles this without extra code.

### D3: Single `UIView` with height constraint drives both states

A single `NSLayoutConstraint` on `inputView.heightAnchor` toggles between 44 and 350. `UIView.animate` + `invalidateIntrinsicContentSize()` produces the same smooth resize animation iOS uses for emoji/dictation keyboard height changes. No second view controller, no additional windows.

**Alternative considered:** Two separate views swapped in/out. Rejected — unnecessary complexity; the height constraint approach is idiomatic UIKit and has zero risk of breaking keyboard frame notifications to the host app.

### D4: Bubble widget is a `UIView` with `UIPanGestureRecognizer`, position in App Group UserDefaults

The draggable widget is a plain `UIView` child of `inputView`. Pan gesture updates the view's center. On gesture end, the position is saved to `UserDefaults(suiteName: appGroupIdentifier)`. On `viewDidLoad`, the saved position is restored.

App Group entitlement is needed for the shared suite — both the extension and host app targets need the same App Group. Full Access entitlement is NOT required (App Groups are local storage, no network).

**Alternative considered:** `NSUserActivity` or iCloud sync for position. Rejected — overkill; position is a trivial CGPoint that only matters on-device.

### D5: Submit triggers — send button required, dwell timer secondary

The send button is always visible and is the primary submit affordance. A dwell timer (1.2s pause after last keystroke) fires as a secondary trigger. Double-space is an optional third trigger.

Submit calls `textDocumentProxy.insertText(composedText)`, clears the internal buffer, and optionally collapses the keyboard.

**Alternative considered:** Timer-only, no button. Rejected — timer duration is hard to calibrate and has no accessible fallback. The button is required for accessibility (WCAG 2.5.4: functionality triggered by timing must have a non-timing alternative).

### D6: Auto-collapse after submit is the default; configurable

After `insertText()` fires, the keyboard collapses back to hint bar. This matches the expected flow: compose → send → continue reading/dictating. A persistent expanded mode (for multiple sequential entries) is a future enhancement, not part of this change.

## Risks / Trade-offs

[44pt hint bar is visible in all apps] → The keyboard now has a visible footprint in collapsed state. This is a deliberate trade-off — the 1pt touch target was unusable. The blur+border treatment minimizes visual weight. Apps with content near the bottom edge (e.g., bottom navigation) will have 44pt of blur overlay they cannot control. Document this clearly in the host app's instructions.

[Drag area limited to bottom ~350pt] → Cannot offer true full-screen widget placement. Market this as a "composition bar" or "input zone," not a "floating keyboard," to set accurate expectations.

[System dock bar still present] → iOS renders ~78pt of dock chrome below the extension regardless. The actual minimum keyboard footprint for users is ~78pt (dock) + 44pt (hint bar) = ~122pt in collapsed state. This is better than a full keyboard (~280pt) but not truly invisible.

[App Group entitlement adds provisioning complexity] → Requires an App Group registered in the Apple Developer Portal, added to both targets. For sideloaded builds, this works with a personal team. For App Store, it's standard but adds one step to the submission setup.

[Auto-collapse timing] → If the user submits and wants to compose again immediately, two taps are needed (submit collapses, then tap to expand again). A "stay open" mode could mitigate this but is deferred.

## Open Questions

- Should the hint bar show any visual indicator at center (a pip, a drag line) or remain fully blank?
- Dwell timer duration: 1.0s, 1.2s, or 1.5s? Needs device testing — too short causes accidental submits, too long feels laggy.
- Should double-space submit be on by default or opt-in? It conflicts with iOS's own double-space → period behavior in some apps.
- Does auto-collapse after submit feel right, or should the bubble stay open and clear for the next composition? Needs user testing.
- App Store path: does the Bubble Input mode satisfy Guideline 4.2 (minimum functionality) for the host app, reducing rejection risk?
