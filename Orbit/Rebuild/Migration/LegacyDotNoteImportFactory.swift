//
//  LegacyDotNoteImportFactory.swift
//  Orbit
//
//  Creates the active legacy import source when the required dependency exists.
//

import Foundation

enum LegacyDotNoteImportFactory {
    static func makeDefaultImportSource() -> LegacyDotNoteImportSource? {
        #if canImport(RealmSwift)
        return try? LegacyRealmStore()
        #else
        return nil
        #endif
    }
}

