//
//  InMemoryDotNoteStore.swift
//  Orbit
//
//  Temporary store used until the legacy import and permanent storage are wired.
//

import Foundation

@MainActor
final class InMemoryDotNoteStore: DotNoteStore {
    private var snapshot: DotNoteStoreSnapshot

    init(snapshot: DotNoteStoreSnapshot = DotNoteStoreSnapshot()) {
        self.snapshot = snapshot
    }

    func loadInitialSnapshot() async throws -> DotNoteStoreSnapshot {
        snapshot
    }

    func addEntry(_ entry: DotNoteEntry) async throws -> DotNoteStoreSnapshot {
        snapshot.entries.insert(entry, at: 0)
        return snapshot
    }
}
