## ADDED Requirements

### Requirement: DwellTimer fires after interval with no reset
`DwellTimer` SHALL fire its callback after the configured interval if `keyDidChange()` is not called again.

#### Scenario: fires after interval
- **WHEN** `keyDidChange()` is called and the interval elapses
- **THEN** the callback fires once

#### Scenario: reset on new keystroke — fires once not twice
- **WHEN** `keyDidChange()` is called, then called again before the interval elapses, then the interval elapses
- **THEN** the callback fires exactly once (from the second call)

#### Scenario: cancel prevents firing
- **WHEN** `keyDidChange()` is called then `cancel()` is called before the interval elapses
- **THEN** the callback does not fire
