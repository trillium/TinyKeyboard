import XCTest

final class TextBufferTests: XCTestCase {

    // MARK: - Helpers

    /// Returns a TextBuffer together with a spy closure that records every
    /// string passed to `insertText`.
    private func makeBuffer() -> (buffer: TextBuffer, inserted: () -> [String]) {
        var calls: [String] = []
        let buffer = TextBuffer { calls.append($0) }
        return (buffer, { calls })
    }

    // MARK: - submit() guard: empty buffer

    func test_submit_emptyBuffer_doesNotCallInsertText() {
        let (buffer, inserted) = makeBuffer()
        buffer.submit()
        XCTAssertTrue(inserted().isEmpty, "insertText must not be called on an empty buffer")
    }

    // MARK: - submit() happy path

    func test_submit_nonEmptyBuffer_callsInsertTextWithComposedText() {
        let (buffer, inserted) = makeBuffer()
        buffer.appendText("hello")
        buffer.submit()
        XCTAssertEqual(inserted(), ["hello"])
    }

    func test_submit_clearsBufferAfterSuccess() {
        let (buffer, _) = makeBuffer()
        buffer.appendText("hello")
        buffer.submit()
        XCTAssertEqual(buffer.composedText, "")
    }

    func test_submit_callsOnSubmitCallback() {
        let (buffer, _) = makeBuffer()
        var onSubmitFired = false
        buffer.onSubmit = { onSubmitFired = true }
        buffer.appendText("hello")
        buffer.submit()
        XCTAssertTrue(onSubmitFired)
    }

    func test_submit_emptyBuffer_doesNotCallOnSubmit() {
        let (buffer, _) = makeBuffer()
        var onSubmitFired = false
        buffer.onSubmit = { onSubmitFired = true }
        buffer.submit()
        XCTAssertFalse(onSubmitFired)
    }

    // MARK: - Double-space detection

    func test_appendText_trailingDoubleSpace_triggersSubmit() {
        let (buffer, inserted) = makeBuffer()
        // Simulate typing "hello" then two spaces (as the text view would send
        // the full current text string each time).
        buffer.appendText("hello  ")
        XCTAssertEqual(inserted(), ["hello"], "trailing double-space should auto-submit sans the two spaces")
    }

    func test_appendText_trailingDoubleSpace_clearsBuffer() {
        let (buffer, _) = makeBuffer()
        buffer.appendText("hello  ")
        XCTAssertEqual(buffer.composedText, "")
    }

    func test_appendText_singleTrailingSpace_doesNotTriggerSubmit() {
        let (buffer, inserted) = makeBuffer()
        buffer.appendText("hello ")
        XCTAssertTrue(inserted().isEmpty, "single trailing space must not trigger submit")
    }

    func test_appendText_leadingDoubleSpace_doesNotTriggerSubmit() {
        let (buffer, inserted) = makeBuffer()
        buffer.appendText("  hello")
        XCTAssertTrue(inserted().isEmpty, "leading double-space must not trigger submit")
    }

    // MARK: - clear()

    func test_clear_removesComposedText() {
        let (buffer, _) = makeBuffer()
        buffer.appendText("draft")
        buffer.clear()
        XCTAssertEqual(buffer.composedText, "")
    }
}
