import CoreGraphics

/// Footprint contract for the keyboard's input view.
///
/// The keyboard is 1pt tall unless the settings panel is showing. The panel
/// shows once per keyboard load (when the user switches into TinyKeyboard) and
/// stays collapsed after the user dismisses it, until iOS loads a new
/// `KeyboardViewController`. Nothing is persisted: the extension stores no data.
struct PanelState: Equatable {
    /// The invisible footprint: same 1pt the keyboard has always had.
    static let collapsedHeight: CGFloat = 1
    /// Panel height: one row of 44pt tap targets plus a little breathing room.
    static let expandedHeight: CGFloat = 52

    private(set) var isCollapsed: Bool

    /// A freshly loaded keyboard starts with the panel showing.
    init(isCollapsed: Bool = false) {
        self.isCollapsed = isCollapsed
    }

    /// Height the input view must be constrained to.
    var height: CGFloat {
        isCollapsed ? Self.collapsedHeight : Self.expandedHeight
    }

    /// Hides the panel. Idempotent; only a new keyboard load brings it back.
    mutating func collapse() {
        isCollapsed = true
    }
}
