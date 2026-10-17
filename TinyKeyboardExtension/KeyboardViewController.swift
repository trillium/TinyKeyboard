import UIKit
import os

/// Near-invisible keyboard extension.
///
/// TinyKeyboard exists only so text fields will accept focus for voice-first
/// users; it takes no screen space of its own. Collapsed, the input view is
/// constrained to 1pt and rendered fully transparent. On load it shows a small
/// settings panel (`SettingsPanelView`) until the user collapses it; the panel
/// stays collapsed until iOS loads a new controller (see `PanelState`). The
/// practical switching affordance when collapsed is the ~78pt system dock
/// (globe/mic/home-indicator) iOS renders beneath every keyboard extension
/// regardless of the extension's own view height; on devices where
/// `needsInputModeSwitchKey` is true this controller also keeps its own globe
/// fallback to satisfy that API requirement, but that button is nested in the
/// 1pt-tall input view, so its own tap target is far below Apple's 44×44pt
/// guidance.
class KeyboardViewController: UIInputViewController {

    /// Lifecycle logging so the (otherwise invisible) extension is observable in
    /// the device syslog. Stream with:
    ///   idevicesyslog -u <udid> -m TinyKeyboard
    /// or filter Console.app by subsystem `com.trillium.TinyKeyboard`.
    private let log = Logger(subsystem: "com.trillium.TinyKeyboard", category: "keyboard")

    /// Current panel state; `state.height` is the only height the input view may have.
    private(set) var state = PanelState()

    private var heightConstraint: NSLayoutConstraint?
    private(set) var panelView: SettingsPanelView?
    private var fallbackGlobe: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        log.notice("viewDidLoad — building input view")

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

        let heightConstraint = inputView.heightAnchor.constraint(equalToConstant: state.height)
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint

        // Invisible spacer gives the layout engine content to measure so the
        // height is honored on device.
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.isAccessibilityElement = false
        inputView.addSubview(spacer)

        NSLayoutConstraint.activate([
            spacer.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            spacer.topAnchor.constraint(equalTo: inputView.topAnchor),
            spacer.bottomAnchor.constraint(equalTo: inputView.bottomAnchor)
        ])

        addPanel(to: inputView)
        addFallbackGlobe(to: inputView)
        applyState(animated: false)
    }

    // MARK: - Panel

    private func addPanel(to inputView: UIInputView) {
        let panel = SettingsPanelView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.onDelete = { [weak self] in self?.textDocumentProxy.deleteBackward() }
        panel.onReturn = { [weak self] in self?.textDocumentProxy.insertText("\n") }
        panel.onDismissKeyboard = { [weak self] in self?.dismissKeyboard() }
        panel.onCollapse = { [weak self] in self?.collapsePanel() }
        // handleInputModeList(from:with:) gives the globe tap-to-advance and
        // long-press-for-picker, which Apple's keyboard guidelines expect.
        panel.globeButton.addTarget(
            self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        inputView.addSubview(panel)

        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            panel.topAnchor.constraint(equalTo: inputView.topAnchor),
            panel.heightAnchor.constraint(equalToConstant: PanelState.expandedHeight)
        ])
        panelView = panel
    }

    /// Hides the panel and returns the keyboard to its 1pt footprint.
    func collapsePanel() {
        guard !state.isCollapsed else { return }
        state.collapse()
        log.notice("panel collapsed")
        applyState(animated: true)
    }

    private func applyState(animated: Bool) {
        heightConstraint?.constant = state.height
        let collapsed = state.isCollapsed
        let updates = {
            self.panelView?.alpha = collapsed ? 0 : 1
            self.view.layoutIfNeeded()
        }
        let finish = { (_: Bool) in
            // Hidden views drop out of hit-testing and accessibility, so a
            // collapsed keyboard offers no phantom controls.
            self.panelView?.isHidden = collapsed
            self.updateFallbackGlobeVisibility()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates, completion: finish)
        } else {
            updates()
            finish(true)
        }
    }

    // MARK: - Globe fallback

    /// Apple requires keyboard extensions to provide a way to switch back
    /// when needsInputModeSwitchKey is true (single-keyboard devices). The
    /// system dock's globe is the practical switching affordance; this
    /// fallback only satisfies the API requirement — nested in the 1pt
    /// input view, its own tap target (~20x1pt) is far below the 44x44pt
    /// guidance. While the panel is showing, the panel's own globe covers it.
    private func addFallbackGlobe(to inputView: UIInputView) {
        let globeButton = UIButton(type: .system)
        globeButton.setImage(UIImage(systemName: "globe"), for: .normal)
        globeButton.tintColor = .systemGray3
        globeButton.accessibilityLabel = "Next keyboard"
        globeButton.accessibilityIdentifier = "tk-fallback-globe"
        globeButton.translatesAutoresizingMaskIntoConstraints = false
        globeButton.addTarget(
            self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        inputView.addSubview(globeButton)

        NSLayoutConstraint.activate([
            globeButton.leadingAnchor.constraint(equalTo: inputView.leadingAnchor, constant: 4),
            globeButton.topAnchor.constraint(equalTo: inputView.topAnchor),
            globeButton.widthAnchor.constraint(equalToConstant: 20),
            globeButton.heightAnchor.constraint(equalToConstant: 1)
        ])
        fallbackGlobe = globeButton
        updateFallbackGlobeVisibility()
    }

    /// `needsInputModeSwitchKey` can change after load (e.g. an external
    /// keyboard connects or another keyboard is enabled), so re-evaluate it on
    /// every layout rather than once in viewDidLoad.
    private func updateFallbackGlobeVisibility() {
        fallbackGlobe?.isHidden = !(needsInputModeSwitchKey && state.isCollapsed)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateFallbackGlobeVisibility()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The measured height is the truth-check for "invisible": when
        // collapsed it should be ~1pt. Anything larger means the constraint
        // lost to the system.
        let height = Double(inputView?.bounds.height ?? -1)
        log.notice("viewDidAppear — inputView height=\(height, format: .fixed(precision: 2))pt")
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        log.debug("textDidChange — focused field active")
    }
}
