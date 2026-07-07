//
//  OrbitUITests.swift
//  OrbitUITests
//
//  Smoke tests for the SwiftUI rebuild shell.
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
        XCTAssertTrue(app.navigationBars["Dot Note"].waitForExistence(timeout: 5))

        app.buttons["new-note-button"].tap()
        XCTAssertTrue(app.navigationBars["New Note"].waitForExistence(timeout: 5))

        app.textFields["entry-title-field"].tap()
        app.textFields["entry-title-field"].typeText("UI Smoke")

        let bodyEditor = app.textViews["entry-body-editor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 2))
        bodyEditor.tap()
        bodyEditor.typeText("Created from UI test")

        app.buttons["entry-save-button"].tap()
        XCTAssertTrue(app.staticTexts["UI Smoke"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Created from UI test"].exists)

        app.staticTexts["UI Smoke"].tap()
        XCTAssertTrue(app.navigationBars["Edit Note"].waitForExistence(timeout: 5))

        app.textFields["entry-title-field"].tap()
        app.textFields["entry-title-field"].typeText(" Updated")
        app.buttons["entry-save-button"].tap()

        XCTAssertTrue(app.staticTexts["UI Smoke Updated"].waitForExistence(timeout: 5))

        app.staticTexts["UI Smoke Updated"].tap()
        XCTAssertTrue(app.navigationBars["Edit Note"].waitForExistence(timeout: 5))
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["No entries"].waitForExistence(timeout: 5))
    }
}
