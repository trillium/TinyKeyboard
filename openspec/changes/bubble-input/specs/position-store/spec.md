## ADDED Requirements

### Requirement: PositionStore round-trips position
`PositionStore.save(_:)` and `PositionStore.load()` SHALL round-trip a CGPoint through the injected UserDefaults.

#### Scenario: save then load returns same point
- **WHEN** `save(CGPoint(x: 120, y: 80))` is called
- **THEN** `load()` returns `CGPoint(x: 120, y: 80)`

#### Scenario: no saved value returns nil
- **WHEN** no position has been saved
- **THEN** `load()` returns nil

#### Scenario: save overwrites previous value
- **WHEN** `save(CGPoint(x: 10, y: 10))` then `save(CGPoint(x: 50, y: 50))` are called
- **THEN** `load()` returns `CGPoint(x: 50, y: 50)`
