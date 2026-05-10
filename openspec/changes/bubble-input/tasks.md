## 1. Project Setup

- [ ] 1.1 Register App Group (`group.com.trillium.TinyKeyboard`) in Apple Developer Portal
- [ ] 1.2 Add App Group capability to host app target in Xcode
- [ ] 1.3 Add App Group capability to keyboard extension target in Xcode

## 2. Collapsed Hint Bar

- [ ] 2.1 Update `heightConstraint.constant` from 1 to 44 in `KeyboardViewController.viewDidLoad`
- [ ] 2.2 Add `UIVisualEffectView` with `systemUltraThinMaterial` blur, pinned to `inputView` bounds
- [ ] 2.3 Set `layer.borderWidth = 1`, `layer.cornerRadius = 12`, `layer.masksToBounds = true` on `inputView`
- [ ] 2.4 Implement `updateBorderColor()` using `traitCollection.userInterfaceStyle` and call from `viewDidLoad` + `traitCollectionDidChange`
- [ ] 2.5 Add `UITapGestureRecognizer` on `inputView` → `handleHintBarTap()`

## 3. State Machine

- [ ] 3.1 Add `isExpanded: Bool` property to `KeyboardViewController`
- [ ] 3.2 Implement `expand()` — animate `heightConstraint.constant` to 350, fade bubble widget in
- [ ] 3.3 Implement `collapse()` — animate `heightConstraint.constant` to 44, fade bubble widget out
- [ ] 3.4 Implement `handleHintBarTap()` — calls `expand()` when not expanded
- [ ] 3.5 Call `invalidateIntrinsicContentSize()` inside `UIView.animate(duration: 0.28, options: .curveEaseInOut)` for both transitions

## 4. Bubble Widget View

- [ ] 4.1 Create `BubbleWidgetView: UIView` with `UITextView`, send `UIButton`, drag handle `UIView`, collapse `UIButton`
- [ ] 4.2 Style send button (right-aligned, `.callout` semibold label, adaptive tint)
- [ ] 4.3 Style drag handle (three 24pt × 3pt rounded lines, centered at top, 50% opacity)
- [ ] 4.4 Style collapse button (top-right, chevron.down SF Symbol, 44pt tap target)
- [ ] 4.5 Add `BubbleWidgetView` as subview of `inputView`, hidden (alpha 0) initially
- [ ] 4.6 Set initial default position (centered horizontally, lower half of expanded frame)

## 5. Drag Gesture

- [ ] 5.1 Attach `UIPanGestureRecognizer` to `BubbleWidgetView`
- [ ] 5.2 Implement pan handler — update `center` with gesture translation, clamp to `inputView.bounds`
- [ ] 5.3 On gesture end (`.ended`), save `center` as `CGPoint` to `UserDefaults(suiteName: appGroupIdentifier)` key `bubbleWidgetPosition`

## 6. Position Persistence

- [ ] 6.1 Define `appGroupIdentifier = "group.com.trillium.TinyKeyboard"` constant
- [ ] 6.2 On `viewDidLoad`, read `bubbleWidgetPosition` from App Group UserDefaults
- [ ] 6.3 If value exists, set `bubbleWidget.center` (clamped to current bounds); otherwise use default

## 7. Text Injection

- [ ] 7.1 Add `composedText: String` buffer property (computed from `bubbleTextView.text`)
- [ ] 7.2 Implement `submit()` — guard non-empty, call `textDocumentProxy.insertText(composedText)`, clear `bubbleTextView.text`, call `collapse()`
- [ ] 7.3 Wire send button `touchUpInside` → `submit()`
- [ ] 7.4 Wire collapse button `touchUpInside` → `collapse()`

## 8. Dwell Timer

- [ ] 8.1 Add `dwellTimer: Timer?` property
- [ ] 8.2 Implement `UITextViewDelegate.textViewDidChange` — invalidate and reschedule `dwellTimer` for 1.2s → `submit()`
- [ ] 8.3 Invalidate timer in `collapse()` and `viewWillDisappear`

## 9. Double-Space Submit

- [ ] 9.1 In `textViewDidChange`, check if last two characters of `textView.text` are both spaces
- [ ] 9.2 If so, trim trailing two spaces from buffer, then call `submit()`

## 10. Host App Instructions Update

- [ ] 10.1 Update `ContentView.swift` setup instructions to document the hint bar tap and bubble mode
- [ ] 10.2 Note the globe key path for switching back to system keyboard
