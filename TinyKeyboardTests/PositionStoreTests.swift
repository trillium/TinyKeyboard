import CoreGraphics
import XCTest

final class PositionStoreTests: XCTestCase {

    // MARK: - Helpers

    /// Creates a PositionStore backed by a fresh ephemeral UserDefaults suite
    /// so tests never pollute the real database.
    private func makeStore() -> PositionStore {
        // Each test gets a unique suite name to guarantee isolation.
        let suiteName = "com.test.PositionStoreTests.\(name)"
        // Remove any leftover data from a previous run.
        UserDefaults().removePersistentDomain(forName: suiteName)
        let defaults = UserDefaults(suiteName: suiteName)!
        return PositionStore(defaults: defaults, key: "bubbleWidgetPosition")
    }

    // MARK: - Round-trip

    func test_saveAndLoad_returnsSamePoint() {
        let store = makeStore()
        let point = CGPoint(x: 120, y: 80)
        store.save(point)
        XCTAssertEqual(store.load(), point)
    }

    // MARK: - No saved value

    func test_load_noSavedValue_returnsNil() {
        let store = makeStore()
        XCTAssertNil(store.load())
    }

    // MARK: - Overwrite

    func test_save_overwritesPreviousValue() {
        let store = makeStore()
        store.save(CGPoint(x: 10, y: 10))
        store.save(CGPoint(x: 50, y: 50))
        XCTAssertEqual(store.load(), CGPoint(x: 50, y: 50))
    }

    // MARK: - Edge cases

    func test_saveOrigin_loadsOrigin() {
        let store = makeStore()
        store.save(.zero)
        // .zero is a valid saved value, not the same as "no value"
        XCTAssertEqual(store.load(), .zero)
    }
}
