//
//  DotNoteStore.swift
//  Orbit
//
//  Storage boundary for the SwiftUI rebuild.
//

import Foundation

struct DotNoteStoreSnapshot: Equatable {
    var entries: [DotNoteEntry]
    var settings: DotNoteSettings?

    init(entries: [DotNoteEntry] = [], settings: DotNoteSettings? = nil) {
        self.entries = entries
        self.settings = settings
    }
}

protocol DotNoteStore {
    @MainActor
    func loadInitialSnapshot() async throws -> DotNoteStoreSnapshot
}
