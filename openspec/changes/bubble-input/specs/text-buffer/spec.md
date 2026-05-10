## ADDED Requirements

### Requirement: TextBuffer submit guard
`TextBuffer.submit()` SHALL call the injected `insertText` closure only when the buffer is non-empty.

#### Scenario: empty buffer — submit is no-op
- **WHEN** `submit()` is called and `composedText` is empty
- **THEN** the `insertText` closure is NOT called

#### Scenario: non-empty buffer — insertText called with composed text
- **WHEN** `submit()` is called and `composedText` is "hello"
- **THEN** the `insertText` closure is called with "hello"

#### Scenario: buffer cleared after submit
- **WHEN** `submit()` is called successfully
- **THEN** `composedText` is empty

### Requirement: Double-space detection
`TextBuffer.appendText(_:)` SHALL detect a trailing double-space and trigger submit, stripping the trailing two spaces from the submitted string.

#### Scenario: trailing double-space triggers submit
- **WHEN** text ending in two consecutive spaces is appended
- **THEN** `submit()` fires with the text minus the trailing two spaces

#### Scenario: single trailing space does not trigger submit
- **WHEN** text ending in a single space is appended
- **THEN** no submit occurs

#### Scenario: leading double-space does not trigger submit
- **WHEN** text beginning with two spaces is appended (not trailing)
- **THEN** no submit occurs
