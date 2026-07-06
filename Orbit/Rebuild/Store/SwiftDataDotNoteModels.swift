//
//  SwiftDataDotNoteModels.swift
//  Orbit
//
//  Persistent SwiftData records for the rebuild store.
//

import Foundation
import SwiftData

@Model
final class DotNoteEntryRecord {
    @Attribute(.unique) var id: UUID
    var kindRawValue: String
    var createdAt: Date
    var title: String
    var weather: String
    var body: String
    var textAlignmentRawValue: String
    var imageData: Data?

    init(
        id: UUID = UUID(),
        kindRawValue: String,
        createdAt: Date = Date(),
        title: String = "",
        weather: String = "",
        body: String = "",
        textAlignmentRawValue: String = DotNoteTextAlignment.left.rawValue,
        imageData: Data? = nil
    ) {
        self.id = id
        self.kindRawValue = kindRawValue
        self.createdAt = createdAt
        self.title = title
        self.weather = weather
        self.body = body
        self.textAlignmentRawValue = textAlignmentRawValue
        self.imageData = imageData
    }
}

@Model
final class DotNoteSettingsRecord {
    @Attribute(.unique) var id: String
    var navigationTitleFontName: String
    var contentTitleFontName: String
    var bodyFontName: String
    var bodyFontSize: Int
    var collectionFilter: Int

    init(
        id: String = "default",
        navigationTitleFontName: String = "",
        contentTitleFontName: String = "",
        bodyFontName: String = "",
        bodyFontSize: Int = 16,
        collectionFilter: Int = 0
    ) {
        self.id = id
        self.navigationTitleFontName = navigationTitleFontName
        self.contentTitleFontName = contentTitleFontName
        self.bodyFontName = bodyFontName
        self.bodyFontSize = bodyFontSize
        self.collectionFilter = collectionFilter
    }
}

