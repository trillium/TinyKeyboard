## ADDED Requirements

### Requirement: Expanded state height
When expanded, the keyboard's `inputView` SHALL animate to 350pt height with the same blur background and border as the collapsed state.

#### Scenario: inputView expands to 350pt on tap
- **WHEN** the user taps the hint bar
- **THEN** `heightConstraint.constant` changes to 350 and `invalidateIntrinsicContentSize()` is called inside a `UIView.animate` block with duration 0.28

---

### Requirement: Bubble widget view
The expanded state SHALL render a `UIView` bubble widget as a subview of `inputView`. The widget SHALL contain:
- A multiline `UITextView` for text entry
- A send `UIButton` (right-aligned)
- A drag handle view (three horizontal lines, centered at top of widget)
- A collapse `UIButton` (top-right corner, chevron-down or ✕)

#### Scenario: Bubble widget appears on expand
- **WHEN** the keyboard transitions to expanded state
- **THEN** the bubble widget's alpha animates from 0 to 1

#### Scenario: Bubble widget hides on collapse
- **WHEN** the keyboard transitions to collapsed state
- **THEN** the bubble widget's alpha animates from 1 to 0

---

### Requirement: Draggable widget
The bubble widget SHALL have a `UIPanGestureRecognizer` that allows repositioning within the `inputView` frame. The widget SHALL not be draggable outside the `inputView` bounds.

#### Scenario: Widget repositions on drag
- **WHEN** the user pans the bubble widget
- **THEN** the widget's center updates with the gesture translation and is clamped to the `inputView` bounds

---

### Requirement: Position persistence
The bubble widget's position SHALL be saved to App Group `UserDefaults` on drag end and restored on `viewDidLoad`.

#### Scenario: Position saves on drag end
- **WHEN** the pan gesture ends
- **THEN** the widget's center is written to `UserDefaults(suiteName: appGroupIdentifier)` under key `bubbleWidgetPosition`

#### Scenario: Position restores on keyboard load
- **WHEN** `viewDidLoad` runs and a saved position exists in App Group UserDefaults
- **THEN** the bubble widget's center is set to the saved position (clamped to current bounds)

#### Scenario: Default position when no saved position
- **WHEN** `viewDidLoad` runs and no saved position exists
- **THEN** the bubble widget is centered horizontally, positioned in the lower half of the expanded frame

---

### Requirement: Collapse button
The bubble widget SHALL include a collapse button that transitions the keyboard back to collapsed state.

#### Scenario: Collapse button collapses keyboard
- **WHEN** the user taps the collapse button
- **THEN** the keyboard transitions to collapsed state and the bubble widget text buffer is preserved (not cleared)
