> **☠️ DEFUNCT — 2026-07-02.** The bubble workflow is confirmed impossible: a keyboard extension cannot present a second keyboard or system dictation to type into its own text view, so the bubble can never receive input. Product target reverted to the original 1px invisible keyboard (see SPEC.md). This file is retained as a historical record only. Do not implement from it.

# TinyKeyboard — Bubble Input Spec

## Concept

TinyKeyboard evolves from a pure "get out of the way" keyboard into a two-state
keyboard: invisible by default, a floating composition bubble on demand.

The keyboard lives as a near-invisible hint bar at the bottom of the screen.
When the user taps it, it expands into a translucent draggable scratchpad — a
"bubble" — where they compose text. On submission, the composed text is injected
into whatever field has focus, and the keyboard collapses back to invisible.

The user sees the full app at all times. The keyboard is felt, not seen.

---

## States

### State 1 — Collapsed (default)

The keyboard sits as a thin, translucent bar anchored to the bottom of the
screen. It is intentionally unobtrusive but visually present: the user knows
something is there.

**Visual:**
- Height: 44pt (touch target) — appears as a thin sliver
- Background: `systemUltraThinMaterial` blur (adapts to light/dark mode)
- Border: 1pt, 50% opacity white/black (adaptive)
- Corner radius: 12pt (top corners only, or all four if floating)
- Content: nothing, or a very subtle centered drag-handle pip (optional)

**Behavior:**
- Tap anywhere on the bar → transition to Expanded
- Does not intercept key input in this state

---

### State 2 — Expanded (bubble mode)

The `inputView` animates open to reveal the full bubble widget. The background
remains translucent — the user can still see the app content beneath.

**Visual:**
- Height: 320–360pt (enough for comfortable text entry + controls)
- Background: `systemUltraThinMaterial` blur, same as collapsed
- Border: same 1pt adaptive border, continuous from collapsed state
- Corner radius: 12pt
- Shadow: subtle (offset 0, 8pt blur, 20% black) to lift it from the page

**Bubble widget (inside the expanded view):**
- A draggable pill/card — can be repositioned within the expanded frame
- Text entry area: multiline, no border of its own, inherits bubble styling
- Send button: right-aligned, always visible
- Drag handle: subtle three-line grip at top of widget
- Collapse button: small ✕ or chevron-down, top-right corner

---

## Interaction Model

```
[COLLAPSED]
    tap anywhere on bar
         ↓
[EXPANDED]
    user types in bubble
         ↓ (submit trigger fires)
    insertText() → focused field receives text
    bubble text clears
         ↓ (auto-collapse or manual)
[COLLAPSED]
```

### Transition: Collapsed → Expanded

- Trigger: tap on the collapsed bar
- Animation: height constraint animates from 44pt → 350pt, `UIView.animate`
  with `invalidateIntrinsicContentSize()`, duration 0.28s, ease-in-out
- Bubble widget fades in (alpha 0 → 1) as height opens

### Transition: Expanded → Collapsed

- Trigger: any submit action (see below), or explicit collapse tap
- Animation: reverse of above — height animates back to 44pt, widget fades out
- Auto-collapse is optional: could keep bubble open for follow-up entries

---

## Submit Triggers

Multiple triggers fire `insertText()` and optionally collapse the keyboard.
At minimum, the Send button is required. Others are layered on.

| Trigger | Default | Notes |
|---|---|---|
| Send button tap | Required | Primary affordance, always visible |
| Dwell timer | 1.2s pause | Secondary, feels intelligent |
| Double-space | Optional | Power user shortcut (classic iOS pattern) |
| Trailing punctuation | Optional | `.` `!` `?` at end of buffer |
| Swipe-right on bubble | Optional | Gestural confirm |

On submit:
1. `textDocumentProxy.insertText(composedText)`
2. Clear internal buffer
3. Optionally collapse (configurable)

---

## Draggable Widget

The bubble widget is a `UIView` with a `UIPanGestureRecognizer`. It can be
repositioned within the expanded `inputView` frame.

**Constraints:**
- Cannot be dragged above the `inputView` boundary (bottom ~350pt of screen)
- Cannot be dragged off-screen horizontally
- Snaps to left/center/right on release (optional, like PIP windows)
- Position persists across keyboard appearances via App Group `UserDefaults`

**Position persistence:**
- Requires an App Group entitlement shared between host app and extension
- Key: `com.trillium.TinyKeyboard.bubblePosition` (CGPoint, archived)
- No Full Access entitlement needed — App Groups are local only

---

## Text Injection

`UIInputViewController` exposes `textDocumentProxy: UITextDocumentProxy`.

```swift
// Insert composed text at cursor position in focused field
textDocumentProxy.insertText(composedText)
```

- Works with any `UITextField` or `UITextView` in any app
- Inserts at current cursor position
- No limit on string length
- Newlines, emoji, special characters all supported
- The extension never sees the full document — privacy is preserved by design

---

## Visual Design Spec

### Color / Material

| Element | Value |
|---|---|
| Background | `UIBlurEffect(style: .systemUltraThinMaterial)` |
| Border color | `UIColor { trait in trait.userInterfaceStyle == .dark ? .white.withAlphaComponent(0.5) : .black.withAlphaComponent(0.5) }` |
| Border width | 1pt |
| Corner radius | 12pt |
| Shadow | color: black 20%, offset: (0, 4), blur: 12pt |

### Dimensions

| State | Height | Notes |
|---|---|---|
| Collapsed | 44pt | Touch target; visually appears as a thin sliver |
| Expanded | 350pt | Enough for ~4 lines of text + controls |

### Typography (bubble widget)

| Element | Style |
|---|---|
| Text input | `.body`, system font, adaptive color |
| Send button label | `.callout`, semibold |
| Placeholder | "Compose..." or empty |

---

## Technical Architecture

### Height toggling

```swift
private var heightConstraint: NSLayoutConstraint!
private var isExpanded = false

func toggle() {
    isExpanded.toggle()
    let target: CGFloat = isExpanded ? 350 : 44
    heightConstraint.constant = target
    UIView.animate(withDuration: 0.28, delay: 0,
                   options: .curveEaseInOut) {
        self.inputView?.invalidateIntrinsicContentSize()
    }
}
```

### Blur background

```swift
let blur = UIBlurEffect(style: .systemUltraThinMaterial)
let blurView = UIVisualEffectView(effect: blur)
inputView.addSubview(blurView)
// pin to edges
```

### Border

```swift
inputView.layer.borderWidth = 1.0
inputView.layer.cornerRadius = 12
inputView.layer.masksToBounds = true
// border color set in traitCollectionDidChange for dark/light mode
```

### Submit

```swift
func submit() {
    guard !composedText.isEmpty else { return }
    textDocumentProxy.insertText(composedText)
    composedText = ""
    textField.text = ""
    if autoCollapse { toggle() }
}
```

---

## Known Constraints

| Constraint | Impact |
|---|---|
| `inputView` anchored to bottom | Widget drag area limited to bottom ~350pt of screen; cannot cover full screen |
| System dock bar (~78pt) | Always rendered below the extension by iOS; outside extension's view hierarchy |
| No full document access | `textDocumentProxy` gives only a limited context window (~few hundred chars) around cursor |
| No focus change callbacks | Extension doesn't know when the user taps to a different text field |
| `UIApplication.shared` unavailable | No access to host app's responder chain or window |

---

## Open Questions

- [ ] Auto-collapse after submit, or keep bubble open?
- [ ] Snap-to-edge behavior on drag release, or free positioning?
- [ ] Dwell timer duration (0.8s? 1.2s?) — needs user testing
- [ ] Should collapsed state show a subtle visual indicator (pip, line) or be fully invisible?
- [ ] Keyboard height in expanded state: fixed 350pt or user-resizable?
- [ ] What happens when the system autofill bar appears above? (outside our control)
- [ ] App Store path: does this feature change the Guideline 4.2 calculus for the host app?

---

## Relationship to Existing Spec

This spec extends `SPEC.md`. The original "near-zero height, no keys, voice-first"
design remains the default behavior. Bubble Input is a second mode layered on
top — the keyboard starts collapsed (fulfilling the original spec) and expands
only on explicit user action.

The original Non-goal "no App Store release" is superseded by the active
App Store publication epic (`TinyKeyboard-2h0`). The host app's Guideline 4.2
concern may be addressed by Bubble Input itself — a functional input method
satisfies "standalone utility" in a way a blank screen does not.
