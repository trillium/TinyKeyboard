import UIKit

/// Near-invisible keyboard extension.
///
/// TinyKeyboard exists only so text fields will accept focus for voice-first
/// users; it takes no screen space of its own. The input view is constrained to
/// 1pt and rendered fully transparent. Keyboard switching is provided by the
/// system dock beneath the extension (the globe key), so this controller
/// renders no UI of its own.
class KeyboardViewController: UIInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Replace the system inputView — the default uses UIInputViewStyle.keyboard
        // which paints opaque keyboard chrome regardless of backgroundColor = .clear.
        // UIInputViewStyle.default skips that private background renderer, so the
        // extension renders truly transparent on device.
        let inputView = UIInputView(frame: .zero, inputViewStyle: .default)
        inputView.allowsSelfSizing = true  // required for height constraints on device
        self.inputView = inputView

        // Clear the root view too — the system renders both layers.
        self.view.backgroundColor = .clear
        inputView.backgroundColor = .clear

        let heightConstraint = inputView.heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true

        // Invisible spacer gives the layout engine content to measure so the
        // 1pt height is honored on device.
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(spacer)

        NSLayoutConstraint.activate([
            spacer.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            spacer.topAnchor.constraint(equalTo: inputView.topAnchor),
            spacer.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
        ])
    }
}
