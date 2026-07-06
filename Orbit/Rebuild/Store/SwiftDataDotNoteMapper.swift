//
//  SwiftDataDotNoteMapper.swift
//  Orbit
//
//  Converts between rebuild-domain models and SwiftData records.
//

import Foundation

extension DotNoteEntry {
    init(record: DotNoteEntryRecord) {
        self.init(
            id: record.id,
            kind: DotNoteEntryKind(rawValue: record.kindRawValue) ?? .diary,
            createdAt: record.createdAt,
            title: record.title,
            weather: record.weather,
            body: record.body,
            textAlignment: DotNoteTextAlignment(rawValue: record.textAlignmentRawValue) ?? .left,
            imageData: record.imageData
        )
    }
}

extension DotNoteEntryRecord {
    convenience init(entry: DotNoteEntry) {
        self.init(
            id: entry.id,
            kindRawValue: entry.kind.rawValue,
            createdAt: entry.createdAt,
            title: entry.title,
            weather: entry.weather,
            body: entry.body,
            textAlignmentRawValue: entry.textAlignment.rawValue,
            imageData: entry.imageData
        )
    }

    func update(with entry: DotNoteEntry) {
        kindRawValue = entry.kind.rawValue
        createdAt = entry.createdAt
        title = entry.title
        weather = entry.weather
        body = entry.body
        textAlignmentRawValue = entry.textAlignment.rawValue
        imageData = entry.imageData
    }
}

extension DotNoteSettings {
    init(record: DotNoteSettingsRecord) {
        self.init(
            navigationTitleFontName: record.navigationTitleFontName,
            contentTitleFontName: record.contentTitleFontName,
            bodyFontName: record.bodyFontName,
            bodyFontSize: record.bodyFontSize,
            collectionFilter: record.collectionFilter
        )
    }
}

extension DotNoteSettingsRecord {
    convenience init(settings: DotNoteSettings) {
        self.init(
            navigationTitleFontName: settings.navigationTitleFontName,
            contentTitleFontName: settings.contentTitleFontName,
            bodyFontName: settings.bodyFontName,
            bodyFontSize: settings.bodyFontSize,
            collectionFilter: settings.collectionFilter
        )
    }

    func update(with settings: DotNoteSettings) {
        navigationTitleFontName = settings.navigationTitleFontName
        contentTitleFontName = settings.contentTitleFontName
        bodyFontName = settings.bodyFontName
        bodyFontSize = settings.bodyFontSize
        collectionFilter = settings.collectionFilter
    }
}

