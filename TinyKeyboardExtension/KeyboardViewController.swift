import UIKit

// MARK: - KeyboardViewController

/// Thin coordinator that wires `KeyboardState`, `TextBuffer`, `DwellTimer`, and
/// `PositionStore` together and manages UIKit layout / animation.
///
/// All meaningful logic lives in the extracted value types. This class is
/// intentionally difficult to unit test (UIInputViewController subclass) and is
/// not covered by XCTest. See `TinyKeyboardTests/` for coverage of the
/// extracted types.
class KeyboardViewController: UIInputViewController {

    // MARK: - Constants

    private enum Layout {
        static let collapsedHeight: CGFloat = 44
        static let expandedHeight: CGFloat = 350
        static let animationDuration: TimeInterval = 0.28
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
        static let dwellInterval: TimeInterval = 1.2
    }

    private let appGroupIdentifier = "group.com.trillium.TinyKeyboard"
    private let positionKey = "bubbleWidgetPosition"

    // MARK: - Extracted logic types

    private var keyboardState = KeyboardState()
    private var textBuffer: TextBuffer!
    private var dwellTimer: DwellTimer!
    private var positionStore: PositionStore!

    // MARK: - UIKit subviews

    private weak var heightConstraint: NSLayoutConstraint?
    private var bubbleWidget: BubbleWidgetView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let inputView = self.inputView else { return }

        setupLogicTypes()
        setupInputView(inputView)
        setupBubbleWidget(inputView)
        restorePosition()

        // Observe state transitions to drive UIKit animations.
        keyboardState.onTransition = { [weak self] value in
            switch value {
            case .expanded:  self?.animateExpand()
            case .collapsed: self?.animateCollapse()
            }
        }

        // iOS 17+ trait change API (replaces deprecated traitCollectionDidChange).
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (_: UIInputViewController, _: UITraitCollection) in
            self?.updateBorderColor()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dwellTimer.cancel()
    }

    // MARK: - Setup: logic types

    private func setupLogicTypes() {
        positionStore = PositionStore(
            defaults: UserDefaults(suiteName: appGroupIdentifier) ?? .standard,
            key: positionKey
        )

        textBuffer = TextBuffer { [weak self] text in
            self?.textDocumentProxy.insertText(text)
        }
        textBuffer.onSubmit = { [weak self] in
            self?.collapse()
        }

        dwellTimer = DwellTimer(interval: Layout.dwellInterval, scheduler: { work in
            DispatchQueue.main.asyncAfter(deadline: .now() + Layout.dwellInterval, execute: work)
        }, callback: { [weak self] in
            self?.textBuffer.submit()
        })
    }

    // MARK: - Setup: inputView

    private func setupInputView(_ inputView: UIView) {
        inputView.backgroundColor = .clear
        inputView.layer.cornerRadius = Layout.cornerRadius
        inputView.layer.borderWidth = Layout.borderWidth
        inputView.layer.masksToBounds = true

        let heightConstraint = inputView.heightAnchor.constraint(
            equalToConstant: Layout.collapsedHeight
        )
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint

        // Blur background.
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: inputView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
        ])

        updateBorderColor()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleHintBarTap))
        inputView.addGestureRecognizer(tap)
    }

    // MARK: - Setup: bubble widget

    private func setupBubbleWidget(_ inputView: UIView) {
        bubbleWidget = BubbleWidgetView()
        bubbleWidget.alpha = 0
        bubbleWidget.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(bubbleWidget)

        NSLayoutConstraint.activate([
            bubbleWidget.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            bubbleWidget.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            bubbleWidget.topAnchor.constraint(equalTo: inputView.topAnchor),
            bubbleWidget.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
        ])

        bubbleWidget.onSend = { [weak self] in
            self?.textBuffer.submit()
        }
        bubbleWidget.onCollapse = { [weak self] in
            self?.collapse()
        }
        bubbleWidget.onTextChange = { [weak self] text in
            self?.textBuffer.appendText(text)
            self?.dwellTimer.keyDidChange()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBubbleDragEnd(_:)),
            name: BubbleWidgetView.didEndDragNotification,
            object: nil
        )
    }

    @objc private func handleBubbleDragEnd(_ notification: Notification) {
        guard let center = notification.object as? CGPoint else { return }
        positionStore.save(center)
    }

    // MARK: - Position restore

    private func restorePosition() {
        // Position is managed by BubbleWidgetView's internal layout. If a saved
        // center is available it is applied after the bubble is visible.
        // Deferred to first expand so bounds are determined.
    }

    // MARK: - Border color

    private func updateBorderColor() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        inputView?.layer.borderColor = isDark
            ? UIColor.white.withAlphaComponent(0.5).cgColor
            : UIColor.black.withAlphaComponent(0.5).cgColor
    }

    // MARK: - State transitions

    @objc private func handleHintBarTap() {
        guard keyboardState.current == .collapsed else { return }
        keyboardState.expand()
    }

    private func expand() {
        keyboardState.expand()
    }

    private func collapse() {
        dwellTimer.cancel()
        keyboardState.collapse()
    }

    // MARK: - Animation

    private func animateExpand() {
        heightConstraint?.constant = Layout.expandedHeight
        UIView.animate(withDuration: Layout.animationDuration, delay: 0,
                       options: .curveEaseInOut) { [weak self] in
            self?.inputView?.invalidateIntrinsicContentSize()
            self?.bubbleWidget.alpha = 1
        } completion: { [weak self] _ in
            self?.applyRestoredPositionIfNeeded()
        }
    }

    private func animateCollapse() {
        heightConstraint?.constant = Layout.collapsedHeight
        UIView.animate(withDuration: Layout.animationDuration, delay: 0,
                       options: .curveEaseInOut) { [weak self] in
            self?.inputView?.invalidateIntrinsicContentSize()
            self?.bubbleWidget.alpha = 0
        }
    }

    private func applyRestoredPositionIfNeeded() {
        guard let saved = positionStore.load() else { return }
        let clamped = clamp(saved, to: bubbleWidget.bounds)
        bubbleWidget.bubbleCenter = clamped
    }

    // MARK: - Helpers

    private func clamp(_ point: CGPoint, to rect: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(point.x, rect.minX), rect.maxX),
            y: min(max(point.y, rect.minY), rect.maxY)
        )
    }
}

// MARK: - BubbleWidgetView

/// Self-contained subview that renders the expanded bubble input UI.
/// It owns the text view, send button, drag handle, and collapse button.
/// Callbacks surface user actions to `KeyboardViewController`.
final class BubbleWidgetView: UIView {

    // MARK: - Callbacks (set by coordinator)

    var onSend: (() -> Void)?
    var onCollapse: (() -> Void)?
    /// Called whenever the text view's text changes; receives the full current string.
    var onTextChange: ((String) -> Void)?

    // MARK: - Subviews

    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let collapseButton = UIButton(type: .system)
    private let dragHandle = UIView()

    /// The draggable "bubble" container that holds controls. Positioned by pan
    /// gesture within the BubbleWidgetView's bounds.
    private let bubbleContainer = UIView()

    // MARK: - Drag

    private var lastCenter: CGPoint = .zero

    // MARK: - Position override (set by coordinator after restore)

    var bubbleCenter: CGPoint {
        get { bubbleContainer.center }
        set { bubbleContainer.center = newValue }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set a default center on first layout if not restored.
        if bubbleContainer.center == .zero || bubbleContainer.center == CGPoint(x: 0, y: 0) {
            bubbleContainer.center = CGPoint(x: bounds.midX, y: bounds.maxY - 80)
        }
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear

        setupBubbleContainer()
        setupDragHandle()
        setupTextView()
        setupSendButton()
        setupCollapseButton()
        setupPanGesture()
    }

    private func setupBubbleContainer() {
        bubbleContainer.backgroundColor = .systemBackground.withAlphaComponent(0.9)
        bubbleContainer.layer.cornerRadius = 16
        bubbleContainer.layer.shadowColor = UIColor.black.cgColor
        bubbleContainer.layer.shadowOpacity = 0.15
        bubbleContainer.layer.shadowRadius = 8
        bubbleContainer.layer.shadowOffset = .zero
        bubbleContainer.frame = CGRect(x: 0, y: 0, width: 280, height: 120)
        addSubview(bubbleContainer)
    }

    private func setupDragHandle() {
        dragHandle.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
        dragHandle.layer.cornerRadius = 1.5
        dragHandle.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.addSubview(dragHandle)
        NSLayoutConstraint.activate([
            dragHandle.centerXAnchor.constraint(equalTo: bubbleContainer.centerXAnchor),
            dragHandle.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: 8),
            dragHandle.widthAnchor.constraint(equalToConstant: 36),
            dragHandle.heightAnchor.constraint(equalToConstant: 3),
        ])
    }

    private func setupTextView() {
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: 24),
            textView.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: -8),
        ])
    }

    private func setupSendButton() {
        let config = UIImage.SymbolConfiguration(textStyle: .callout, scale: .medium)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
        sendButton.setImage(image, for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 4),
            sendButton.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func setupCollapseButton() {
        let config = UIImage.SymbolConfiguration(textStyle: .footnote, scale: .small)
        let image = UIImage(systemName: "chevron.down", withConfiguration: config)
        collapseButton.setImage(image, for: .normal)
        collapseButton.tintColor = .secondaryLabel
        collapseButton.addTarget(self, action: #selector(didTapCollapse), for: .touchUpInside)
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.addSubview(collapseButton)
        NSLayoutConstraint.activate([
            collapseButton.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -4),
            collapseButton.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: 0),
            collapseButton.widthAnchor.constraint(equalToConstant: 44),
            collapseButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bubbleContainer.addGestureRecognizer(pan)
    }

    // MARK: - Actions

    @objc private func didTapSend() {
        onSend?()
    }

    @objc private func didTapCollapse() {
        onCollapse?()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            lastCenter = bubbleContainer.center
        case .changed:
            let translation = gesture.translation(in: self)
            let newCenter = CGPoint(
                x: lastCenter.x + translation.x,
                y: lastCenter.y + translation.y
            )
            bubbleContainer.center = clamped(newCenter)
        case .ended, .cancelled:
            // Notify coordinator to persist position.
            NotificationCenter.default.post(
                name: BubbleWidgetView.didEndDragNotification,
                object: bubbleContainer.center
            )
        default:
            break
        }
    }

    private func clamped(_ point: CGPoint) -> CGPoint {
        let halfW = bubbleContainer.bounds.width / 2
        let halfH = bubbleContainer.bounds.height / 2
        return CGPoint(
            x: min(max(point.x, halfW), bounds.width - halfW),
            y: min(max(point.y, halfH), bounds.height - halfH)
        )
    }

    // MARK: - Notifications

    static let didEndDragNotification = Notification.Name("BubbleWidgetView.didEndDrag")
}

// MARK: - UITextViewDelegate

extension BubbleWidgetView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onTextChange?(textView.text ?? "")
    }
}
