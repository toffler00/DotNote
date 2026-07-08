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
        XCTAssertTrue(app.buttons["create-toggle"].waitForExistence(timeout: 5))

        // Expand the create row and pick "memo".
        app.buttons["create-toggle"].tap()
        XCTAssertTrue(app.buttons["create-memo"].waitForExistence(timeout: 2))
        app.buttons["create-memo"].tap()

        XCTAssertTrue(app.otherElements["memo-overlay"].waitForExistence(timeout: 5))

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
        XCTAssertTrue(app.otherElements["memo-overlay"].waitForExistence(timeout: 5))

        app.textFields["entry-title-field"].tap()
        app.textFields["entry-title-field"].typeText(" Updated")
        app.buttons["entry-save-button"].tap()

        XCTAssertTrue(app.staticTexts["UI Smoke Updated"].waitForExistence(timeout: 5))

        app.staticTexts["UI Smoke Updated"].tap()
        XCTAssertTrue(app.otherElements["memo-overlay"].waitForExistence(timeout: 5))
        app.buttons["entry-delete-button"].tap()

        // Deleting the only entry falls back to the empty state.
        XCTAssertTrue(app.staticTexts["아직 기록이 없어요"].waitForExistence(timeout: 5))
    }
}
