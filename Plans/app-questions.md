# TinyKeyboard — What Is This App Supposed To Do?

> Questions generated after reading `Plans/app-store-readiness.md`, `README.md`, `SPEC.md`, `BUBBLE_SPEC.md`, the openspec bubble-input proposal, and every Swift file in both targets. The four documents and the code describe **four different products**. Answering these questions defines which one goes to the App Store.

## Resolved 2026-07-02

**The bubble workflow is defunct — it cannot work.** A keyboard extension cannot summon a second keyboard or system dictation to type into its own text view, so the bubble can never receive input. The product target is the **original 1px invisible keyboard, with no other features**. `SPEC.md` is the canonical spec again; `BUBBLE_SPEC.md` and the openspec `bubble-input` change are retained as historical record only.

Effect on the sections below: **A answered, B resolved (negatively), D moot**. E (settings panel) remains open — it is separate from the bubble. C (globe key) resolved 2026-07-28. F (App Store scope) and H (testing) remain live. In G, the bubble-dependent questions are moot; secure-field and hardware-keyboard questions stay.

---

## A. Product Identity — which keyboard is the real one? ✅ Answered 2026-07-02

**Answered:** the canonical product is the **1px invisible keyboard** (the README description). `SPEC.md` has been rewritten and is canonical again. The 44pt bar + bubble in the shipped code is a regression to revert.

The core contradiction, in one table:

| Source | Collapsed keyboard is... |
|---|---|
| `Plans/app-store-readiness.md` | "at most 1 pixel tall — invisible" |
| `README.md` | "1pt transparent keyboard", globe key only |
| `SPEC.md` | ~30pt bar with a centered globe button |
| `BUBBLE_SPEC.md` | 44pt translucent blur hint bar, tap to expand |
| **Shipped code** (`KeyboardViewController.swift:17`) | 44pt clear tappable bar + 350pt draggable bubble mode |

1. **Which description is canonical for the App Store product?** — **Resolved:** the 1px invisible keyboard. The 44pt collapsed floor in the code is to be reverted.
2. **Does the original fully-invisible mode still exist as a requirement?** — **Resolved:** yes — it is the *only* mode. The 44pt minimum is a regression to fix.
3. **Is the collapsed bar supposed to be visible or not?** — **Resolved:** there is no bar at all; the keyboard is fully invisible (1pt, transparent).
4. **Should `SPEC.md` be rewritten?** — **Resolved:** done 2026-07-02. `SPEC.md` is the source of truth; App Store submission is now a goal, not a non-goal.

## B. How does text get INTO the bubble? (the biggest unknown) ✅ Resolved 2026-07-02

**Resolved:** it can't — this section's premise was correct and is exactly why the bubble is dead. There is no mechanism for a keyboard extension to receive typed or dictated text into its own views.

5. ~~**What is the intended input mechanism for the bubble's text view?**~~ — **Resolved:** there isn't one; the bubble is struck.
6. ~~**Who is the iOS voice user, concretely?**~~ — **Moot for the bubble.** (Still useful context for marketing copy, but no longer gates the product.)
7. ~~**If the bubble can't receive text in v1, is bubble mode in scope for the App Store submission at all?**~~ — **Resolved:** no. v1 (and the product, period) is the pure get-out-of-the-way 1px keyboard. There is no bubble v2.

## C. Keyboard switching — a likely App Store rejection ✅ Resolved 2026-07-28

> 2026-07-02 note, from the restored beads (`TinyKeyboard-2h0.7`, filed 2026-03-18): iOS renders a system dock bar (~78pt — globe icon, mic icon, home-indicator safe area) *beneath* every keyboard extension, outside the extension's view hierarchy. This partially answers Q8/Q9 — the **system** dock provides the globe, so switching away works without the extension rendering one. It also bounds the product claim: the realistic minimum footprint is ~78pt of system chrome, not a true 1px — "1px" means 1px of *our* keyboard. Q8's remaining live part: verify on home-button devices where `needsInputModeSwitchKey` is true and no system dock exists.

**Resolved 2026-07-28:** `KeyboardViewController` now checks `needsInputModeSwitchKey` in `viewDidLoad` and, when true, adds its own 1pt-tall (visually invisible, tappable) globe button wired to `advanceToNextInputMode()` — see `TinyKeyboardExtension/KeyboardViewController.swift`. The extension is no longer relying solely on the system dock's globe.

8. ~~**Where is the globe key?**~~ — **Resolved:** the system dock's globe covers Face ID devices; `KeyboardViewController` now also adds its own fallback globe button whenever `needsInputModeSwitchKey` is true, so home-button/single-keyboard configurations are covered too.
9. ~~**How does the user escape TinyKeyboard when the collapsed bar is invisible?**~~ — **Resolved:** the system globe on devices where it's rendered, or the extension's own invisible-but-tappable globe fallback where `needsInputModeSwitchKey` requires one.

## D. The dwell timer and submit behavior 🚫 Moot 2026-07-02

**Moot:** the entire dwell/submit feature belongs to the bubble, which is struck. None of these questions need answers; the code they reference is slated for removal.

10. ~~**Is auto-submit-on-pause actually wanted?**~~ — moot, feature struck.
11. ~~**Should submit collapse the bubble?**~~ — moot, feature struck.
12. ~~**What should Send do in messaging apps?**~~ — moot, feature struck.
13. ~~**Stale text after submit — intended?**~~ — moot, feature struck (the bug is real but the code is being removed, not fixed).
14. ~~**Double-space submit strips the spaces and fires**~~ — moot, feature struck.

## E. The settings panel (plan §4) — nearly everything is open ⏳ Still open

> 2026-07-02 note: the settings panel is separate from the bubble and remains undecided. These questions stay open, with the caveat that bubble-flavored candidates (dwell settings, bubble position, state-machine states) no longer apply, and the collapsed footprint the panel must honor is now **1px** (Q20 answered by the revert).

The plan: "Rotating into TinyKeyboard from another keyboard brings up a small settings/control panel... collapsing hides the panel until the keyboard is reloaded."

15. **What does "rotating into" mean** — switching to TinyKeyboard via the globe key, or physically rotating the device?
16. **Is the settings panel the existing bubble widget repurposed, a third state alongside collapsed/expanded, or a replacement for the bubble?** The state machine (`KeyboardState`) currently has exactly two states.
17. **Which settings does it control?** Candidates visible in the code/specs: dwell duration, dwell on/off, auto-collapse after submit, double-space submit, hint-bar visibility, bubble position reset. What's the v1 list?
18. **What counts as a "reload" that brings the panel back** — keyboard dismissed and reshown, switched away and back, host app changed, or device reboot?
19. **Should settings live in the keyboard, the host app, or both?** The App Group (`group.com.trillium.TinyKeyboard`) already exists for position persistence, so host-app settings synced via UserDefaults is available. The host app currently shows onboarding instructions, an enabled-status badge, a test field, and a privacy policy screen — no settings yet.
20. **"Panel must not increase the keyboard's footprint while collapsed"** — collapsed footprint is currently 44pt, not the plan's 1px. Which number is the contract the panel must honor?

## F. App Store scope and review posture

21. **What is the host app's standalone utility story for Guideline 4.2?** Today it's onboarding instructions + a live enabled-status indicator + a test field + a privacy policy screen + build info. BUBBLE_SPEC conjectures bubble input itself satisfies 4.2 — but if the bubble can't receive text (§B), that argument weakens. What's the reviewer-facing answer?
22. ~~**Privacy policy content: can we state zero collection flatly?**~~ — **Resolved 2026-07-28:** yes. The host app now ships an in-app privacy policy screen (`PrivacyPolicyView` in `TinyKeyboard/ContentView.swift`) stating no data collection, no keystroke logging, no clipboard access, and no network entitlements. `RequestsOpenAccess=false` remains set. No planned feature currently needs Full Access; WhisperFlow/settings-sync/analytics are still exploratory (see `Plans/app-store-readiness.md` §5) and would need to revisit this if ever pursued.
23. **Pricing: free, paid, or freemium?** This shapes 4.2 risk (paid utilities get more scrutiny) and whether a settings panel gates features.
24. **Device support: iPhone-only, or iPad too?** SPEC.md declares iPad a non-goal; App Store metadata must commit. (Note: on iPad, Scribble might make the bubble genuinely typeable — which cuts against excluding it.)
25. **iOS floor: is 17+ still right** (`SPEC.md`), and what's the device-size test matrix for the "1px/44pt across all screen sizes" verification the plan asks about?
26. **The epic `TinyKeyboard-2h0` is referenced in BUBBLE_SPEC as the App Store publication epic** — the beads DB should be the tracker of record; does it reflect the plan's five workstreams?

## G. Robustness unknowns (plan §1 needs a definition of "reliable") — partially mooted 2026-07-02

27. **Secure text entry:** iOS silently swaps to the system keyboard for password fields. Is any in-app messaging needed, or is silent-swap acceptable UX? *(still live)*
28. ~~**Landscape:** expanded height is a fixed 350pt — on an iPhone SE in landscape that's the entire screen.~~ — **Moot:** no expanded mode; 1px is 1px in any orientation.
29. **Hardware keyboard attached:** what should the keyboard do when a Bluetooth keyboard is active and iOS minimizes the software keyboard? *(still live)*
30. ~~**Position restore across contexts**~~ — **Moot:** bubble position persistence struck with the bubble.
31. ~~**`viewWillDisappear` cancels the dwell timer but doesn't submit** — draft lifecycle?~~ — **Moot:** no drafts, no dwell timer.

## H. Testing (plan §2) — the premise looks outdated

32. **The plan says "Trillium does not currently know how to write Swift tests / needs XCTest setup" — but the repo has 5 unit test files covering all four extracted logic types plus a `KeyboardLayoutUITests` XCUITest target.** Is the real gap (a) these tests don't actually run (`xcodebuild test` broken?), (b) no CI, or (c) knowing how to extend them? The plan's ask should be re-scoped to the actual gap.
33. **What's the definition of done for "test the 1px height across all iPhone screen sizes"** given the code's collapsed height is 44pt and XCUITest cannot host a keyboard extension inside arbitrary third-party apps — is testing inside the host app's test field sufficient evidence?

---

*Suggested next step: ~~answer A first (which product is v1), then B (input mechanism)~~ — done 2026-07-02. ~~C (globe key)~~ — done 2026-07-28. Remaining live sections: E (settings panel), F (App Store scope, minus Q22), G27/G29, H (testing).*
