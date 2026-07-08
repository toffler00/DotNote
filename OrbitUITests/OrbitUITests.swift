//
//  OrbitUITests.swift
//  OrbitUITests
//
//  Smoke tests for the SwiftUI rebuild shell (redesigned calendar-first home).
//

import XCTest

final class OrbitUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("--dotnote-ui-testing")
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testCreateEditAndDeleteMemo() {
        // Home renders the expandable create control.
        let createToggle = app.buttons["create-toggle"]
        XCTAssertTrue(createToggle.waitForHittable(timeout: 5))

        // Expand the create row and pick "memo".
        createToggle.tap()
        let createMemo = app.buttons["create-memo"]
        XCTAssertTrue(createMemo.waitForHittable(timeout: 2))
        createMemo.tap()

        XCTAssertTrue(app.textFields["entry-title-field"].waitForExistence(timeout: 5))

        app.textFields["entry-title-field"].tap()
        app.textFields["entry-title-field"].typeText("UI Smoke")

        let bodyEditor = app.textViews["entry-body-editor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 2))
        bodyEditor.tap()
        bodyEditor.typeText("Created from UI test")

        app.buttons["entry-save-button"].tap()

        // The new entry appears in the selected day's list on the home screen.
        XCTAssertTrue(app.staticTexts["UI Smoke"].waitForExistence(timeout: 5))

        app.staticTexts["UI Smoke"].tap()
        XCTAssertTrue(app.textFields["entry-title-field"].waitForExistence(timeout: 5))

        app.textFields["entry-title-field"].tap()
        app.textFields["entry-title-field"].typeText(" Updated")
        app.buttons["entry-save-button"].tap()

        XCTAssertTrue(app.staticTexts["UI Smoke Updated"].waitForExistence(timeout: 5))

        app.staticTexts["UI Smoke Updated"].tap()
        XCTAssertTrue(app.textFields["entry-title-field"].waitForExistence(timeout: 5))
        app.buttons["entry-delete-button"].tap()

        // Deleting the only entry falls back to the empty state.
        XCTAssertTrue(app.staticTexts["아직 기록이 없어요"].waitForExistence(timeout: 5))
    }
}

private extension XCUIElement {
    func waitForHittable(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if exists && isHittable {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return exists && isHittable
    }
}
