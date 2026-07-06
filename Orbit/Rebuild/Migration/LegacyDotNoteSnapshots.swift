//
//  LegacyDotNoteSnapshots.swift
//  Orbit
//
//  Lightweight legacy data shapes used before importing into the new store.
//

import Foundation

struct LegacyDotNoteContentSnapshot: Equatable {
    var type: String
    var createdAt: Date
    var createdAtMonth: String
    var title: String
    var weather: String
    var body: String
    var contentsAlignment: String
    var imageData: Data?

    init(
        type: String,
        createdAt: Date,
        createdAtMonth: String,
        title: String,
        weather: String,
        body: String,
        contentsAlignment: String,
        imageData: Data?
    ) {
        self.type = type
        self.createdAt = createdAt
        self.createdAtMonth = createdAtMonth
        self.title = title
        self.weather = weather
        self.body = body
        self.contentsAlignment = contentsAlignment
        self.imageData = imageData
    }
}

struct LegacyDotNoteSettingsSnapshot: Equatable {
    var navigationTitleFontName: String
    var contentTitleFontName: String
    var bodyFontName: String
    var bodyFontSize: Int
    var collectionFilter: Int

    init(
        navigationTitleFontName: String,
        contentTitleFontName: String,
        bodyFontName: String,
        bodyFontSize: Int,
        collectionFilter: Int
    ) {
        self.navigationTitleFontName = navigationTitleFontName
        self.contentTitleFontName = contentTitleFontName
        self.bodyFontName = bodyFontName
        self.bodyFontSize = bodyFontSize
        self.collectionFilter = collectionFilter
    }
}
