import XCTest

/// Guards the submission claims that live in the extension's Info.plist: the
/// privacy answers say "no Full Access, no data collection", so a stray
/// `RequestsOpenAccess = true` must fail the build, not slip into review.
final class ExtensionManifestTests: XCTestCase {

    private func extensionInfo() throws -> [String: Any] {
        let plugIns = try XCTUnwrap(Bundle.main.builtInPlugInsURL, "host app has no PlugIns directory")
        let appex = plugIns.appendingPathComponent("TinyKeyboardExtension.appex")
        let data = try Data(contentsOf: appex.appendingPathComponent("Info.plist"))
        return try XCTUnwrap(
            try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
    }

    func testIsAKeyboardExtension() throws {
        let ext = try XCTUnwrap(extensionInfo()["NSExtension"] as? [String: Any])
        XCTAssertEqual(ext["NSExtensionPointIdentifier"] as? String, "com.apple.keyboard-service")
    }

    func testDoesNotRequestFullAccess() throws {
        let ext = try XCTUnwrap(extensionInfo()["NSExtension"] as? [String: Any])
        let attributes = try XCTUnwrap(ext["NSExtensionAttributes"] as? [String: Any])
        XCTAssertEqual(attributes["RequestsOpenAccess"] as? Bool, false)
    }

    func testExtensionBundleIdIsChildOfApp() throws {
        let appId = try XCTUnwrap(Bundle.main.bundleIdentifier)
        XCTAssertEqual(try extensionInfo()["CFBundleIdentifier"] as? String, appId + ".keyboard")
    }
}
