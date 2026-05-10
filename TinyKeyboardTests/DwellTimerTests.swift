import XCTest
@testable import TinyKeyboardExtension

/// Tests for `DwellTimer` using a synchronous, controllable scheduler.
///
/// The scheduler used in tests captures each work item into a variable.
/// Calling `fireScheduled()` executes the most recently scheduled item
/// synchronously, simulating interval elapse without real wall-clock time.
final class DwellTimerTests: XCTestCase {

    // MARK: - Helpers

    /// A minimal synchronous test scheduler. Captures the most recently
    /// scheduled work item so tests can fire it on demand.
    private class SyncScheduler {
        /// The most recently scheduled work item, or nil if none is pending.
        var pending: (() -> Void)?

        /// The closure that the DwellTimer injects as its `scheduler` argument.
        lazy var schedule: (@escaping () -> Void) -> Void = { [weak self] work in
            self?.pending = work
        }

        /// Fires the most recently scheduled item, if any, and clears it.
        func fireScheduled() {
            pending?()
            pending = nil
        }
    }

    private func makeTimer(
        scheduler: SyncScheduler,
        callback: @escaping () -> Void
    ) -> DwellTimer {
        DwellTimer(interval: 1.2, scheduler: scheduler.schedule, callback: callback)
    }

    // MARK: - Fires after interval

    func test_keyDidChange_firesCallbackAfterInterval() {
        let scheduler = SyncScheduler()
        var callCount = 0
        let timer = makeTimer(scheduler: scheduler) { callCount += 1 }

        timer.keyDidChange()
        XCTAssertEqual(callCount, 0, "callback must not fire before interval elapses")

        scheduler.fireScheduled()
        XCTAssertEqual(callCount, 1, "callback must fire exactly once after interval elapses")
    }

    // MARK: - Reset on new keystroke — fires once not twice

    func test_keyDidChange_reset_firesOnlyOnce() {
        let scheduler = SyncScheduler()
        var callCount = 0
        let timer = makeTimer(scheduler: scheduler) { callCount += 1 }

        timer.keyDidChange() // first keystroke — schedules item A
        let staleItem = scheduler.pending // hold on to the stale scheduled item

        timer.keyDidChange() // second keystroke — schedules item B (generation advances)

        // Fire stale item A — must be discarded (generation mismatch)
        staleItem?()
        XCTAssertEqual(callCount, 0, "stale scheduled item must not fire callback")

        // Fire current item B — must fire
        scheduler.fireScheduled()
        XCTAssertEqual(callCount, 1, "current scheduled item must fire callback exactly once")
    }

    // MARK: - cancel() prevents firing

    func test_cancel_preventsCallback() {
        let scheduler = SyncScheduler()
        var callCount = 0
        let timer = makeTimer(scheduler: scheduler) { callCount += 1 }

        timer.keyDidChange()
        timer.cancel()
        scheduler.fireScheduled()

        XCTAssertEqual(callCount, 0, "callback must not fire after cancel()")
    }

    // MARK: - keyDidChange after cancel restarts timer

    func test_keyDidChange_afterCancel_restartsTimer() {
        let scheduler = SyncScheduler()
        var callCount = 0
        let timer = makeTimer(scheduler: scheduler) { callCount += 1 }

        timer.keyDidChange()
        timer.cancel()
        scheduler.fireScheduled() // discarded by cancel

        timer.keyDidChange() // restart
        scheduler.fireScheduled()

        XCTAssertEqual(callCount, 1, "callback must fire once after restart following cancel")
    }
}
