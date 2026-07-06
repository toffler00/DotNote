//
//  LegacyRealmStore.swift
//  Orbit
//
//  Reads the existing Realm database when RealmSwift is available.
//

import Foundation

#if canImport(RealmSwift)
import RealmSwift

final class LegacyRealmStore {
    private let realm: Realm

    init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration) throws {
        var importConfiguration = configuration
        importConfiguration.objectTypes = [
            User.self,
            Content.self,
            Settings.self
        ]
        self.realm = try Realm(configuration: importConfiguration)
    }

    var sourceDescription: String {
        "Realm"
    }

    var sourceFileURL: URL? {
        realm.configuration.fileURL
    }

    var defaultRealmFileURL: URL? {
        sourceFileURL
    }

    func loadContentSnapshots() -> [LegacyDotNoteContentSnapshot] {
        realm.objects(Content.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .map { content in
                LegacyDotNoteContentSnapshot(
                    type: content.type,
                    createdAt: content.createdAt,
                    createdAtMonth: content.createdAtMonth,
                    title: content.title,
                    weather: content.weather,
                    body: content.body,
                    contentsAlignment: content.contentsAlignment,
                    imageData: content.image
                )
            }
    }

    func loadSettingsSnapshot() -> LegacyDotNoteSettingsSnapshot? {
        realm.objects(Settings.self).first.map { settings in
            LegacyDotNoteSettingsSnapshot(
                navigationTitleFontName: settings.naviTitleFont,
                contentTitleFontName: settings.contentTitleFont,
                bodyFontName: settings.contentsFont,
                bodyFontSize: settings.contentsFontSize,
                collectionFilter: settings.collectionFilter
            )
        }
    }

    func loadEntries() -> [DotNoteEntry] {
        loadContentSnapshots().map(DotNoteEntry.init(legacy:))
    }

    func loadSettings() -> DotNoteSettings? {
        loadSettingsSnapshot().map(DotNoteSettings.init(legacy:))
    }
}

extension LegacyRealmStore: LegacyDotNoteImportSource {
    func loadLegacySnapshot() throws -> DotNoteStoreSnapshot {
        DotNoteStoreSnapshot(
            entries: loadEntries(),
            settings: loadSettings(),
            diagnostics: DotNoteStoreDiagnostics(
                hasLegacyImportSource: true,
                legacyImportSourceDescription: sourceDescription,
                legacyImportFileURL: sourceFileURL
            )
        )
    }
}
#endif
