import UIKit
import os

/// Near-invisible keyboard extension.
///
/// TinyKeyboard exists only so text fields will accept focus for voice-first
/// users; it takes no screen space of its own. The input view is constrained to
/// 1pt and rendered fully transparent. Keyboard switching is provided by the
/// system dock beneath the extension (the globe key), so this controller
/// renders no UI of its own.
class KeyboardViewController: UIInputViewController {

    /// Lifecycle logging so the (otherwise invisible) extension is observable in
    /// the device syslog. Stream with:
    ///   idevicesyslog -u <udid> -m TinyKeyboard
    /// or filter Console.app by subsystem `com.trillium.TinyKeyboard`.
    private let log = Logger(subsystem: "com.trillium.TinyKeyboard", category: "keyboard")

    override func viewDidLoad() {
        super.viewDidLoad()
        log.notice("viewDidLoad — building 1pt transparent input view")

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The measured height is the truth-check for "invisible": it should be
        // ~1pt. Anything larger means the constraint lost to the system.
        let height = Double(inputView?.bounds.height ?? -1)
        log.notice("viewDidAppear — inputView height=\(height, format: .fixed(precision: 2))pt")
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        log.debug("textDidChange — focused field active")
    }
}
