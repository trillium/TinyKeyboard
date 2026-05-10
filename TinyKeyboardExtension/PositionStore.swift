import CoreGraphics
import Foundation

/// Persists and restores the bubble widget's on-screen position.
///
/// `PositionStore` wraps UserDefaults with an injectable instance so unit tests
/// can supply an ephemeral `UserDefaults(suiteName:)` and avoid polluting the
/// real defaults database.
struct PositionStore {

    // MARK: - Constants

    private enum Keys {
        static let x = "xCoordinate"
        static let y = "yCoordinate"
    }

    // MARK: - Dependencies

    private let defaults: UserDefaults
    private let key: String

    // MARK: - Init

    init(defaults: UserDefaults, key: String) {
        self.defaults = defaults
        self.key = key
    }

    // MARK: - Interface

    /// Persists `point` to UserDefaults.
    func save(_ point: CGPoint) {
        defaults.set(point.x, forKey: xKey)
        defaults.set(point.y, forKey: yKey)
        defaults.set(true, forKey: savedFlagKey)
    }

    /// Returns the most recently saved point, or `nil` if no position has been
    /// saved yet.
    func load() -> CGPoint? {
        guard defaults.bool(forKey: savedFlagKey) else { return nil }
        let x = defaults.double(forKey: xKey)
        let y = defaults.double(forKey: yKey)
        return CGPoint(x: x, y: y)
    }

    // MARK: - Private helpers

    private var xKey: String { "\(key).x" }
    private var yKey: String { "\(key).y" }
    private var savedFlagKey: String { "\(key).saved" }
}
