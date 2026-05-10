/// Manages the text being composed in the bubble widget.
///
/// `TextBuffer` is a plain Swift class with zero UIKit dependency so it can be
/// instantiated and exercised directly in unit tests.
class TextBuffer {

    // MARK: - State

    /// The current composed text.
    private(set) var composedText: String = ""

    /// Called after a successful `submit()` (i.e., when the buffer was non-empty
    /// and `insertText` was called). Use this to trigger collapse.
    var onSubmit: (() -> Void)?

    // MARK: - Dependencies

    /// Injected closure that writes text into the host document. In production
    /// this is `textDocumentProxy.insertText`. In tests it is a spy closure.
    private let insertText: (String) -> Void

    // MARK: - Init

    init(insertText: @escaping (String) -> Void) {
        self.insertText = insertText
    }

    // MARK: - Interface

    /// Appends `text` to `composedText`, then checks for a trailing
    /// double-space, which triggers an automatic submit (stripping the
    /// two trailing spaces before submission).
    func appendText(_ text: String) {
        composedText = text
        if composedText.hasSuffix("  ") {
            // Strip trailing double-space then submit.
            composedText = String(composedText.dropLast(2))
            submit()
        }
    }

    /// Submits the composed text. Guard: does nothing when `composedText` is
    /// empty. On success: calls `insertText`, clears the buffer, calls
    /// `onSubmit`.
    func submit() {
        guard !composedText.isEmpty else { return }
        let text = composedText
        insertText(text)
        composedText = ""
        onSubmit?()
    }

    /// Clears the buffer without submitting.
    func clear() {
        composedText = ""
    }
}
