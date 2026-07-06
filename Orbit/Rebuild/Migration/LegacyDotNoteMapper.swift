//
//  LegacyDotNoteMapper.swift
//  Orbit
//
//  Converts legacy Realm snapshots into rebuild-domain models.
//

import Foundation

extension DotNoteEntryKind {
    init(legacyType: String) {
        switch legacyType {
        case "memo":
            self = .memo
        case "drawing":
            self = .drawing
        case "diary":
            self = .diary
        default:
            self = .diary
        }
    }
}

extension DotNoteTextAlignment {
    init(legacyValue: String) {
        switch legacyValue {
        case "center":
            self = .center
        case "right":
            self = .right
        default:
            self = .left
        }
    }
}

extension DotNoteEntry {
    init(legacy snapshot: LegacyDotNoteContentSnapshot) {
        self.init(
            kind: DotNoteEntryKind(legacyType: snapshot.type),
            createdAt: snapshot.createdAt,
            title: snapshot.title,
            weather: snapshot.weather,
            body: snapshot.body,
            textAlignment: DotNoteTextAlignment(legacyValue: snapshot.contentsAlignment),
            imageData: snapshot.imageData
        )
    }
}

extension DotNoteSettings {
    init(legacy snapshot: LegacyDotNoteSettingsSnapshot) {
        self.init(
            navigationTitleFontName: snapshot.navigationTitleFontName,
            contentTitleFontName: snapshot.contentTitleFontName,
            bodyFontName: snapshot.bodyFontName,
            bodyFontSize: snapshot.bodyFontSize,
            collectionFilter: snapshot.collectionFilter
        )
    }
}
