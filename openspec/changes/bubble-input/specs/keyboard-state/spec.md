## ADDED Requirements

### Requirement: KeyboardState enum
The system SHALL define `enum KeyboardState { case collapsed, expanded }` with transition methods.

#### Scenario: initial state is collapsed
- **WHEN** a KeyboardState is initialized
- **THEN** its value is `.collapsed`

#### Scenario: expand transitions to expanded
- **WHEN** `expand()` is called on a collapsed state
- **THEN** state becomes `.expanded`

#### Scenario: expand while already expanded is a no-op
- **WHEN** `expand()` is called on an already-expanded state
- **THEN** state remains `.expanded` and no transition fires

#### Scenario: collapse transitions to collapsed
- **WHEN** `collapse()` is called on an expanded state
- **THEN** state becomes `.collapsed`

#### Scenario: collapse while already collapsed is a no-op
- **WHEN** `collapse()` is called on an already-collapsed state
- **THEN** state remains `.collapsed` and no transition fires
