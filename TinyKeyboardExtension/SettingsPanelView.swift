import UIKit

/// The small control strip shown when the user rotates into TinyKeyboard.
///
/// Controls act on the focused field through the controller's callbacks; the
/// view itself reads nothing from the text field. Every button is at least
/// 44×44pt and carries an accessibility identifier so XCUITest (and Voice
/// Control's "tap <name>") can address it.
final class SettingsPanelView: UIView {

    enum Identifier {
        static let panel = "tk-panel"
        static let globe = "tk-panel-globe"
        static let delete = "tk-panel-delete"
        static let `return` = "tk-panel-return"
        static let dismiss = "tk-panel-dismiss"
        static let collapse = "tk-panel-collapse"
    }

    let globeButton = SettingsPanelView.makeButton(
        symbol: "globe", label: "Next keyboard", identifier: Identifier.globe)
    let deleteButton = SettingsPanelView.makeButton(
        symbol: "delete.left", label: "Delete", identifier: Identifier.delete)
    let returnButton = SettingsPanelView.makeButton(
        symbol: "return", label: "Return", identifier: Identifier.return)
    let dismissButton = SettingsPanelView.makeButton(
        symbol: "keyboard.chevron.compact.down", label: "Hide keyboard", identifier: Identifier.dismiss)
    let collapseButton = SettingsPanelView.makeButton(
        symbol: "chevron.down", label: "Collapse panel", identifier: Identifier.collapse)

    var onDelete: () -> Void = {}
    var onReturn: () -> Void = {}
    var onDismissKeyboard: () -> Void = {}
    var onCollapse: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .secondarySystemBackground
        accessibilityIdentifier = Identifier.panel

        deleteButton.addAction(UIAction { [weak self] _ in self?.onDelete() }, for: .touchUpInside)
        returnButton.addAction(UIAction { [weak self] _ in self?.onReturn() }, for: .touchUpInside)
        dismissButton.addAction(UIAction { [weak self] _ in self?.onDismissKeyboard() }, for: .touchUpInside)
        collapseButton.addAction(UIAction { [weak self] _ in self?.onCollapse() }, for: .touchUpInside)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(
            arrangedSubviews: [globeButton, deleteButton, returnButton, dismissButton, spacer, collapseButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private static func makeButton(symbol: String, label: String, identifier: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol), for: .normal)
        button.tintColor = .label
        button.accessibilityLabel = label
        button.accessibilityIdentifier = identifier
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        return button
    }
}
