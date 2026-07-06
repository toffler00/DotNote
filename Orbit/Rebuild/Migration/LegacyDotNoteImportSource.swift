//
//  LegacyDotNoteImportSource.swift
//  Orbit
//
//  Boundary for one-time imports from legacy app storage.
//

import Foundation

protocol LegacyDotNoteImportSource {
    func loadLegacySnapshot() throws -> DotNoteStoreSnapshot
}

