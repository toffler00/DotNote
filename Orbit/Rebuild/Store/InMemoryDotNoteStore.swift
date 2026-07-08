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

    func updateEntry(_ entry: DotNoteEntry) async throws -> DotNoteStoreSnapshot {
        guard let index = snapshot.entries.firstIndex(where: { $0.id == entry.id }) else {
            return snapshot
        }

        snapshot.entries[index] = entry
        snapshot.entries.sort { $0.createdAt > $1.createdAt }
        return snapshot
    }

    func deleteEntry(id: DotNoteEntry.ID) async throws -> DotNoteStoreSnapshot {
        snapshot.entries.removeAll { $0.id == id }
        return snapshot
    }

    func updateSettings(_ settings: DotNoteSettings) async throws -> DotNoteStoreSnapshot {
        snapshot.settings = settings
        return snapshot
    }

    func deleteAllData() async throws -> DotNoteStoreSnapshot {
        snapshot.entries.removeAll()
        snapshot.settings = nil
        return snapshot
    }
}
