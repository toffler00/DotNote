//
//  LegacyDotNoteImportSource.swift
//  Orbit
//
//  Boundary for one-time imports from legacy app storage.
//

import Foundation

protocol LegacyDotNoteImportSource {
    var sourceDescription: String { get }
    var sourceFileURL: URL? { get }

    func loadLegacySnapshot() throws -> DotNoteStoreSnapshot
}

extension LegacyDotNoteImportSource {
    var sourceDescription: String {
        String(describing: Self.self)
    }

    var sourceFileURL: URL? {
        nil
    }
}
