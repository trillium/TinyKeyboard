## 1. Project Setup

- [ ] 1.1 Register App Group (`group.com.trillium.TinyKeyboard`) in Apple Developer Portal
- [ ] 1.2 Add App Group capability to host app target in Xcode
- [ ] 1.3 Add App Group capability to keyboard extension target in Xcode

## 2. Test Target Setup

- [ ] 2.1 Add a unit test target `TinyKeyboardTests` to the Xcode project
- [ ] 2.2 Confirm test target can import extension module (or use direct file inclusion)

## 3. KeyboardState

- [ ] 3.1 Write failing tests: initial state collapsed, expand/collapse transitions, no-op when already in state
- [ ] 3.2 Implement `KeyboardState.swift` to pass tests

## 4. TextBuffer

- [ ] 4.1 Write failing tests: empty guard, insertText call with correct string, buffer clear after submit, double-space detection (trailing fires, single no-op, leading no-op)
- [ ] 4.2 Implement `TextBuffer.swift` to pass tests

## 5. DwellTimer

- [ ] 5.1 Write failing tests: fires after interval, resets on new keystroke (fires once), cancel prevents fire
- [ ] 5.2 Implement `DwellTimer.swift` with injectable scheduler closure to pass tests

## 6. PositionStore

- [ ] 6.1 Write failing tests: round-trip, nil when empty, overwrite
- [ ] 6.2 Implement `PositionStore.swift` with injectable UserDefaults to pass tests

## 7. Collapsed Hint Bar (UIKit — visual, not unit tested)

- [ ] 7.1 Update `heightConstraint.constant` from 1 to 44 in `KeyboardViewController.viewDidLoad`
- [ ] 7.2 Add `UIVisualEffectView` with `systemUltraThinMaterial` blur, pinned to `inputView` bounds
- [ ] 7.3 Set `layer.borderWidth = 1`, `layer.cornerRadius = 12`, `layer.masksToBounds = true` on `inputView`
- [ ] 7.4 Implement `updateBorderColor()` and call from `viewDidLoad` + `traitCollectionDidChange`
- [ ] 7.5 Add `UITapGestureRecognizer` on `inputView` → `handleHintBarTap()`

## 8. State Machine Wiring

- [ ] 8.1 Add `KeyboardState` instance to `KeyboardViewController`
- [ ] 8.2 Implement `expand()` — update state, animate height to 350, fade bubble widget in
- [ ] 8.3 Implement `collapse()` — update state, animate height to 44, fade bubble widget out
- [ ] 8.4 Implement `handleHintBarTap()` — calls `expand()` when collapsed

## 9. Bubble Widget View (UIKit — visual)

- [ ] 9.1 Create `BubbleWidgetView: UIView` with `UITextView`, send `UIButton`, drag handle `UIView`, collapse `UIButton`
- [ ] 9.2 Style: send button right-aligned, drag handle centered at top, collapse button top-right with 44pt tap target
- [ ] 9.3 Add as subview of `inputView`, alpha 0 initially
- [ ] 9.4 Set initial default position (centered horizontally, lower half of expanded frame)

## 10. Drag Gesture

- [ ] 10.1 Attach `UIPanGestureRecognizer` to `BubbleWidgetView`
- [ ] 10.2 Implement pan handler — update `center` with gesture translation, clamp via `clamp(_:to:)`
- [ ] 10.3 On gesture end, call `PositionStore.save(center)`

## 11. Text Injection Wiring

- [ ] 11.1 Instantiate `TextBuffer` in `KeyboardViewController`, inject `textDocumentProxy.insertText` as the closure
- [ ] 11.2 Wire `BubbleWidgetView.textView` changes → `TextBuffer.appendText(_:)`
- [ ] 11.3 Wire send button → `TextBuffer.submit()`
- [ ] 11.4 Wire collapse button → `collapse()`
- [ ] 11.5 Wire `TextBuffer` onSubmit callback → `collapse()`

## 12. Dwell Timer Wiring

- [ ] 12.1 Instantiate `DwellTimer` in `KeyboardViewController` with 1.2s interval
- [ ] 12.2 Call `dwellTimer.keyDidChange()` from `UITextViewDelegate.textViewDidChange`
- [ ] 12.3 Wire `DwellTimer` callback → `TextBuffer.submit()`
- [ ] 12.4 Cancel timer in `collapse()` and `viewWillDisappear`

## 13. Position Restore

- [ ] 13.1 On `viewDidLoad`, call `PositionStore.load()` and set bubble widget center if non-nil

## 14. Host App Instructions Update

- [ ] 14.1 Update `ContentView.swift` to document hint bar tap and bubble mode
