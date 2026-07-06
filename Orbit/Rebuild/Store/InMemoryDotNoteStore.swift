//
//  InMemoryDotNoteStore.swift
//  Orbit
//
//  Temporary store used until the legacy import and permanent storage are wired.
//

import Foundation

struct InMemoryDotNoteStore: DotNoteStore {
    private let snapshot: DotNoteStoreSnapshot

    init(snapshot: DotNoteStoreSnapshot = DotNoteStoreSnapshot()) {
        self.snapshot = snapshot
    }

    func loadInitialSnapshot() async throws -> DotNoteStoreSnapshot {
        snapshot
    }
}
