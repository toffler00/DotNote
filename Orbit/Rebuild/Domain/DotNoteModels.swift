//
//  DotNoteModels.swift
//  Orbit
//
//  Rebuild-domain models that are independent of Realm and UIKit.
//

import Foundation

enum DotNoteEntryKind: String, Codable, CaseIterable, Identifiable {
    case diary
    case memo
    case drawing

    var id: String { rawValue }
}

struct DotNoteEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: DotNoteEntryKind
    var createdAt: Date
    var title: String
    var weather: String
    var body: String
    var textAlignment: DotNoteTextAlignment
    var imageData: Data?

    init(
        id: UUID = UUID(),
        kind: DotNoteEntryKind,
        createdAt: Date = Date(),
        title: String = "",
        weather: String = "",
        body: String = "",
        textAlignment: DotNoteTextAlignment = .left,
        imageData: Data? = nil
    ) {
        self.id = id
        self.kind = kind
        self.createdAt = createdAt
        self.title = title
        self.weather = weather
        self.body = body
        self.textAlignment = textAlignment
        self.imageData = imageData
    }
}

enum DotNoteTextAlignment: String, Codable, CaseIterable, Identifiable {
    case left
    case center
    case right

    var id: String { rawValue }
}

struct DotNoteSettings: Codable, Equatable {
    var navigationTitleFontName: String
    var contentTitleFontName: String
    var bodyFontName: String
    var bodyFontSize: Int
    var collectionFilter: Int

    init(
        navigationTitleFontName: String = "",
        contentTitleFontName: String = "",
        bodyFontName: String = "",
        bodyFontSize: Int = 16,
        collectionFilter: Int = 0
    ) {
        self.navigationTitleFontName = navigationTitleFontName
        self.contentTitleFontName = contentTitleFontName
        self.bodyFontName = bodyFontName
        self.bodyFontSize = bodyFontSize
        self.collectionFilter = collectionFilter
    }
}
