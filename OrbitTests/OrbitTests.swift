//
//  OrbitTests.swift
//  OrbitTests
//
//  Created by ilhan won on 2018. 8. 11..
//  Copyright © 2018년 orbit. All rights reserved.
//

import XCTest
@testable import Orbit

class OrbitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        XCTAssertTrue(true)
    }

    @MainActor
    func testSwiftDataStoreAddsEntry() async throws {
        let store = SwiftDataDotNoteStore(
            modelContainer: try DotNoteModelContainer.make(isStoredInMemoryOnly: true)
        )
        let createdAt = Date(timeIntervalSince1970: 1_234)
        let entry = DotNoteEntry(
            kind: .memo,
            createdAt: createdAt,
            title: "Saved memo",
            body: "Stored in SwiftData"
        )

        let snapshot = try await store.addEntry(entry)

        XCTAssertEqual(snapshot.entries, [entry])
        XCTAssertFalse(snapshot.diagnostics.hasLegacyImportSource)
    }

    @MainActor
    func testAppModelAddsTrimmedMemo() async throws {
        let appModel = DotNoteAppModel(store: InMemoryDotNoteStore())

        await appModel.addMemo(title: "  Draft  ", body: "  Body text  ")

        XCTAssertEqual(appModel.entries.count, 1)
        XCTAssertEqual(appModel.entries.first?.kind, .memo)
        XCTAssertEqual(appModel.entries.first?.title, "Draft")
        XCTAssertEqual(appModel.entries.first?.body, "Body text")
        XCTAssertEqual(appModel.loadState, .loaded)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
