import UIKit
import XCTest

/// Exercises the real `KeyboardViewController` constraint system at the
/// widths of the iPhones we ship to (iPhone SE through Pro Max, portrait and
/// landscape). `KeyboardViewController.swift` is compiled into this test
/// bundle directly, since the extension itself cannot be imported.
final class KeyboardViewControllerTests: XCTestCase {

    /// iPhone SE (320) … iPhone 17 Pro Max (440), plus landscape widths.
    private let widths: [CGFloat] = [320, 375, 390, 402, 430, 440, 568, 667, 874, 932]

    private func makeController() -> KeyboardViewController {
        let controller = KeyboardViewController()
        controller.loadViewIfNeeded()
        return controller
    }

    /// Hosts the controller's input view at `width` and lets Auto Layout resolve it.
    private func resolvedHeight(of controller: KeyboardViewController, width: CGFloat) throws -> CGFloat {
        let inputView = try XCTUnwrap(controller.inputView)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 800))
        inputView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inputView)
        NSLayoutConstraint.activate([
            inputView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            inputView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            inputView.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        container.layoutIfNeeded()
        defer { inputView.removeFromSuperview() }
        return inputView.frame.height
    }

    func testStartsWithPanelExpandedOnEveryWidth() throws {
        for width in widths {
            let controller = makeController()
            XCTAssertEqual(
                try resolvedHeight(of: controller, width: width), PanelState.expandedHeight,
                "expanded height at width \(width)")
            XCTAssertFalse(try XCTUnwrap(controller.panelView).isHidden)
        }
    }

    func testCollapsedFootprintIsOnePointOnEveryWidth() throws {
        for width in widths {
            let controller = makeController()
            controller.collapsePanel()
            XCTAssertEqual(
                try resolvedHeight(of: controller, width: width), 1,
                "collapsed height at width \(width)")
        }
    }

    func testCollapseButtonCollapsesPanel() throws {
        let controller = makeController()
        let panel = try XCTUnwrap(controller.panelView)
        panel.collapseButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(controller.state.isCollapsed)
        XCTAssertEqual(try resolvedHeight(of: controller, width: 390), 1)
    }

    func testCollapsedPanelDropsOutOfHitTesting() throws {
        let controller = makeController()
        controller.collapsePanel()
        let panel = try XCTUnwrap(controller.panelView)
        let hidden = expectation(description: "panel hidden after collapse animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if panel.isHidden { hidden.fulfill() }
        }
        wait(for: [hidden], timeout: 2)
    }

    func testCollapseTwiceIsHarmless() throws {
        let controller = makeController()
        controller.collapsePanel()
        controller.collapsePanel()
        XCTAssertEqual(try resolvedHeight(of: controller, width: 390), 1)
    }

    func testEveryPanelButtonMeetsMinimumTapTarget() throws {
        let controller = makeController()
        let panel = try XCTUnwrap(controller.panelView)
        _ = try resolvedHeight(of: controller, width: 320)  // narrowest supported width
        panel.layoutIfNeeded()
        let buttons = [
            panel.globeButton, panel.deleteButton, panel.returnButton,
            panel.dismissButton, panel.collapseButton
        ]
        for button in buttons {
            let size = button.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            XCTAssertGreaterThanOrEqual(size.width, 44, button.accessibilityIdentifier ?? "?")
            XCTAssertGreaterThanOrEqual(size.height, 44, button.accessibilityIdentifier ?? "?")
        }
    }

    func testPanelButtonsAreAddressableByVoiceAndAutomation() throws {
        let controller = makeController()
        let panel = try XCTUnwrap(controller.panelView)
        let buttons = [
            panel.globeButton, panel.deleteButton, panel.returnButton,
            panel.dismissButton, panel.collapseButton
        ]
        for button in buttons {
            XCTAssertFalse(button.accessibilityLabel?.isEmpty ?? true)
            XCTAssertFalse(button.accessibilityIdentifier?.isEmpty ?? true)
        }
        XCTAssertEqual(Set(buttons.compactMap(\.accessibilityIdentifier)).count, buttons.count)
    }

    func testPanelCallbacksFire() throws {
        let controller = makeController()
        let panel = try XCTUnwrap(controller.panelView)
        var deletes = 0, returns = 0, dismisses = 0
        panel.onDelete = { deletes += 1 }
        panel.onReturn = { returns += 1 }
        panel.onDismissKeyboard = { dismisses += 1 }
        panel.deleteButton.sendActions(for: .touchUpInside)
        panel.returnButton.sendActions(for: .touchUpInside)
        panel.dismissButton.sendActions(for: .touchUpInside)
        XCTAssertEqual([deletes, returns, dismisses], [1, 1, 1])
    }
}
