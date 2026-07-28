import UIKit
import os

/// Near-invisible keyboard extension.
///
/// TinyKeyboard exists only so text fields will accept focus for voice-first
/// users; it takes no screen space of its own. The input view is constrained to
/// 1pt and rendered fully transparent. Keyboard switching is normally provided
/// by the system dock beneath the extension (the globe key); on devices where
/// `needsInputModeSwitchKey` is true this controller also adds its own
/// 1pt-tall (tappable but visually invisible) globe fallback to stay
/// compliant with Apple's switching requirement.
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

        // Apple requires keyboard extensions to provide a way to switch back
        // when needsInputModeSwitchKey is true (single-keyboard devices). The
        // system dock's globe covers most configurations, but that's not
        // guaranteed everywhere, so provide a tappable (if visually
        // invisible, at 1pt tall) fallback to stay compliant.
        if needsInputModeSwitchKey {
            log.notice("needsInputModeSwitchKey is true — adding globe fallback button")
            addGlobeButton(to: inputView)
        }
    }

    private func addGlobeButton(to inputView: UIInputView) {
        let globeButton = UIButton(type: .system)
        globeButton.setImage(UIImage(systemName: "globe"), for: .normal)
        globeButton.tintColor = .systemGray3
        globeButton.translatesAutoresizingMaskIntoConstraints = false
        globeButton.addTarget(self, action: #selector(globeTapped), for: .touchUpInside)
        inputView.addSubview(globeButton)

        NSLayoutConstraint.activate([
            globeButton.leadingAnchor.constraint(equalTo: inputView.leadingAnchor, constant: 4),
            globeButton.topAnchor.constraint(equalTo: inputView.topAnchor),
            globeButton.widthAnchor.constraint(equalToConstant: 20),
            globeButton.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    @objc private func globeTapped() {
        advanceToNextInputMode()
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
