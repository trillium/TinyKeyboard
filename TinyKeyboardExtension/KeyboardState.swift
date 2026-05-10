/// State machine for the keyboard's collapsed / expanded modes.
///
/// `KeyboardState` is a plain Swift value type with zero UIKit dependency so it
/// can be instantiated and exercised directly in unit tests.
struct KeyboardState {

    enum Value {
        case collapsed
        case expanded
    }

    private(set) var current: Value = .collapsed

    /// Called when the state transitions between values.
    /// The closure receives the new state. Not called when the state is already
    /// in the target state (no-op transitions are silent).
    var onTransition: ((Value) -> Void)?

    // MARK: - Transitions

    /// Transitions to `.expanded`. No-op if already expanded.
    mutating func expand() {
        guard current != .expanded else { return }
        current = .expanded
        onTransition?(.expanded)
    }

    /// Transitions to `.collapsed`. No-op if already collapsed.
    mutating func collapse() {
        guard current != .collapsed else { return }
        current = .collapsed
        onTransition?(.collapsed)
    }
}
