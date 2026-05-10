## ADDED Requirements

### Requirement: Send button submission
The bubble widget's send button SHALL call `textDocumentProxy.insertText(composedText)`, clear the text buffer, and collapse the keyboard.

#### Scenario: Send button injects text and collapses
- **WHEN** the user taps the send button and the text buffer is non-empty
- **THEN** `textDocumentProxy.insertText(composedText)` is called, the `UITextView` is cleared, and the keyboard transitions to collapsed state

#### Scenario: Send button does nothing on empty buffer
- **WHEN** the user taps the send button and the text buffer is empty
- **THEN** no `insertText` call is made and the keyboard remains expanded

---

### Requirement: Dwell timer submission
The keyboard SHALL start a 1.2s timer after each keystroke. If the timer fires without a new keystroke and the buffer is non-empty, it SHALL submit identically to the send button.

#### Scenario: Dwell timer fires after pause
- **WHEN** the user stops typing for 1.2s and the buffer is non-empty
- **THEN** `textDocumentProxy.insertText(composedText)` is called, the buffer clears, and the keyboard collapses

#### Scenario: Dwell timer resets on new keystroke
- **WHEN** the user types a new character before the 1.2s timer fires
- **THEN** the timer resets to 1.2s from the new keystroke

#### Scenario: Dwell timer does not fire on empty buffer
- **WHEN** 1.2s elapses and the buffer is empty
- **THEN** no `insertText` call is made

---

### Requirement: Double-space submission
The keyboard SHALL detect a double-space (two consecutive space characters with no intervening characters) as a submit trigger, submitting the buffer excluding the trailing double-space.

#### Scenario: Double-space triggers submit
- **WHEN** the user types a space immediately following another space
- **THEN** the trailing two spaces are removed from the buffer and `textDocumentProxy.insertText(composedText)` is called

#### Scenario: Non-consecutive spaces do not trigger submit
- **WHEN** the user types a space after a non-space character
- **THEN** the space is added to the buffer normally and no submit occurs

---

### Requirement: Buffer is internal to the extension
The text buffer SHALL be held in memory as a `String` property on `KeyboardViewController`. It SHALL NOT be written to disk, App Group storage, or any network endpoint.

#### Scenario: Buffer is not persisted between keyboard appearances
- **WHEN** the keyboard is dismissed and re-shown
- **THEN** the text buffer is empty
