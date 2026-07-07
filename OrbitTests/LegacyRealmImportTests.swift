//
//  LegacyRealmImportTests.swift
//  OrbitTests
//
//  Verifies the read-only Realm import path used by the SwiftData rebuild.
//

import RealmSwift
import XCTest
@testable import Orbit

final class LegacyRealmImportTests: XCTestCase {
    func testLoadLegacySnapshotFromRealmFile() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default.removeItem(at: directoryURL)
        }

        let realmURL = directoryURL.appendingPathComponent("default.realm")
        let configuration = Realm.Configuration(
            fileURL: realmURL,
            objectTypes: [
                User.self,
                Content.self,
                Settings.self
            ]
        )
        let realm = try Realm(configuration: configuration)
        let createdAt = Date(timeIntervalSince1970: 1_546_300_800)
        let imageData = Data([0x01, 0x02, 0x03])

        try realm.write {
            let content = Content()
            content.type = "memo"
            content.createdAt = createdAt
            content.createdAtMonth = "2019.01"
            content.title = "Legacy memo"
            content.weather = "sunny"
            content.body = "Imported body"
            content.contentsAlignment = "center"
            content.image = imageData
            realm.add(content)

            let settings = Settings()
            settings.naviTitleFont = "LegacyNavigationFont"
            settings.contentTitleFont = "LegacyTitleFont"
            settings.contentsFont = "LegacyBodyFont"
            settings.contentsFontSize = 19
            settings.collectionFilter = 2
            realm.add(settings)
        }

        let store = try LegacyRealmStore(configuration: configuration)
        let snapshot = try store.loadLegacySnapshot()

        XCTAssertEqual(snapshot.entries.count, 1)
        XCTAssertEqual(snapshot.entries.first?.kind, .memo)
        XCTAssertEqual(snapshot.entries.first?.createdAt, createdAt)
        XCTAssertEqual(snapshot.entries.first?.title, "Legacy memo")
        XCTAssertEqual(snapshot.entries.first?.weather, "sunny")
        XCTAssertEqual(snapshot.entries.first?.body, "Imported body")
        XCTAssertEqual(snapshot.entries.first?.textAlignment, .center)
        XCTAssertEqual(snapshot.entries.first?.imageData, imageData)

        XCTAssertEqual(snapshot.settings?.navigationTitleFontName, "LegacyNavigationFont")
        XCTAssertEqual(snapshot.settings?.contentTitleFontName, "LegacyTitleFont")
        XCTAssertEqual(snapshot.settings?.bodyFontName, "LegacyBodyFont")
        XCTAssertEqual(snapshot.settings?.bodyFontSize, 19)
        XCTAssertEqual(snapshot.settings?.collectionFilter, 2)

        XCTAssertTrue(snapshot.diagnostics.hasLegacyImportSource)
        XCTAssertEqual(snapshot.diagnostics.legacyImportSourceDescription, "Realm")
        XCTAssertEqual(snapshot.diagnostics.legacyImportFileURL, realmURL)
    }

    func testLoadLegacySnapshotFromExternalRealmFixtureWhenAvailable() throws {
        let realmURL = try externalRealmFixtureURL()
        let configuration = Realm.Configuration(
            fileURL: realmURL,
            readOnly: true,
            objectTypes: [
                User.self,
                Content.self,
                Settings.self
            ]
        )

        let store = try LegacyRealmStore(configuration: configuration)
        let snapshot = try store.loadLegacySnapshot()

        XCTAssertTrue(snapshot.diagnostics.hasLegacyImportSource)
        XCTAssertEqual(snapshot.diagnostics.legacyImportSourceDescription, "Realm")
        XCTAssertEqual(snapshot.diagnostics.legacyImportFileURL, realmURL)
        XCTAssertFalse(
            snapshot.entries.isEmpty && snapshot.settings == nil,
            "The legacy Realm fixture opened, but no content or settings were imported."
        )
    }

    private func externalRealmFixtureURL() throws -> URL {
        if let path = ProcessInfo.processInfo.environment["DOTNOTE_LEGACY_REALM_FILE"],
           !path.isEmpty {
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw XCTSkip("DOTNOTE_LEGACY_REALM_FILE does not exist: \(url.path)")
            }
            return url
        }

        let fixtureURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/LegacyRealm/default.realm")
        guard FileManager.default.fileExists(atPath: fixtureURL.path) else {
            throw XCTSkip("No external legacy Realm fixture is available.")
        }
        return fixtureURL
    }
}
