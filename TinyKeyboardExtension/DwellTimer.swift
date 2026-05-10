/// Fires a callback after a configurable interval following the most recent
/// `keyDidChange()` call. Resetting before the interval fires cancels the
/// previous pending callback and restarts the countdown.
///
/// The scheduler closure is injectable so tests can fire it synchronously
/// without real wall-clock delays. In production, pass a scheduler that wraps
/// `DispatchQueue.main.asyncAfter`.
///
/// ### Production usage
/// ```swift
/// let timer = DwellTimer(interval: 1.2, scheduler: { work in
///     DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
/// }, callback: { textBuffer.submit() })
/// ```
///
/// ### Test usage
/// Supply a scheduler that captures the work item and fires it on demand, or
/// fires it immediately (synchronously) to test the "fires" path, or never
/// fires it to test the "cancel prevents fire" path.
class DwellTimer {

    // MARK: - Dependencies

    private let interval: TimeInterval
    /// Schedules a delayed work item. The closure receives the work to schedule.
    /// Implementations must call the work item after `interval` elapses (or
    /// synchronously in tests).
    private let scheduler: (@escaping () -> Void) -> Void
    private let callback: () -> Void

    // MARK: - State

    /// A monotonically increasing generation counter. Each `keyDidChange()`
    /// increments it. The scheduled work item captures the generation at
    /// scheduling time; if the counter has advanced when the item fires, it
    /// is a stale item and is discarded.
    private var generation: Int = 0
    private var isCancelled: Bool = false

    // MARK: - Init

    init(
        interval: TimeInterval,
        scheduler: @escaping (@escaping () -> Void) -> Void,
        callback: @escaping () -> Void
    ) {
        self.interval = interval
        self.scheduler = scheduler
        self.callback = callback
    }

    // MARK: - Interface

    /// Signals that a key event occurred. Resets the dwell countdown.
    func keyDidChange() {
        isCancelled = false
        generation &+= 1
        let capturedGeneration = generation
        scheduler { [weak self] in
            guard let self else { return }
            guard !self.isCancelled, self.generation == capturedGeneration else { return }
            self.callback()
        }
    }

    /// Cancels any pending callback. A subsequent `keyDidChange()` restarts the
    /// timer from scratch.
    func cancel() {
        isCancelled = true
    }
}
