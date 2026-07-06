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
        self.realm = try Realm(configuration: configuration)
    }

    var defaultRealmFileURL: URL? {
        Realm.Configuration.defaultConfiguration.fileURL
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
#endif
