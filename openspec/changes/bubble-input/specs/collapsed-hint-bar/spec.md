## ADDED Requirements

### Requirement: Hint bar height and touch target
The keyboard's `inputView` SHALL have a height of 44pt, replacing the previous 1pt height.

#### Scenario: inputView renders at 44pt
- **WHEN** the keyboard extension loads
- **THEN** `inputView` has a height constraint of 44pt at priority 999

#### Scenario: Touch anywhere on the bar expands to bubble mode
- **WHEN** the user taps anywhere within the 44pt inputView frame
- **THEN** the keyboard transitions to the expanded state

---

### Requirement: Translucent blur background
The hint bar SHALL use `UIBlurEffect(style: .systemUltraThinMaterial)` as its background, covering the full `inputView` frame.

#### Scenario: Background adapts to light mode
- **WHEN** the device is in light mode
- **THEN** the blur renders the light-mode ultra-thin material appearance

#### Scenario: Background adapts to dark mode
- **WHEN** the device is in dark mode
- **THEN** the blur renders the dark-mode ultra-thin material appearance

---

### Requirement: Border
The hint bar SHALL render a 1pt border in adaptive color (white at 50% opacity in dark mode, black at 50% opacity in light mode) with a corner radius of 12pt.

#### Scenario: Border color responds to trait collection changes
- **WHEN** `traitCollectionDidChange` fires
- **THEN** `inputView.layer.borderColor` is updated to match the current user interface style

---

### Requirement: Collapse animation
The transition from expanded state to collapsed state SHALL animate the `inputView` height from 350pt to 44pt over 0.28s with ease-in-out timing.

#### Scenario: Keyboard height animates on collapse
- **WHEN** the keyboard transitions to collapsed state
- **THEN** `heightConstraint.constant` changes to 44 and `invalidateIntrinsicContentSize()` is called inside a `UIView.animate` block with duration 0.28
