//
//  SwiftDataDotNoteStore.swift
//  Orbit
//
//  Permanent SwiftData-backed store for the rebuild app.
//

import Foundation
import SwiftData

struct SwiftDataDotNoteStore: DotNoteStore {
    private let modelContainer: ModelContainer
    private let legacyImportSource: LegacyDotNoteImportSource?
    private let legacyImportState: LegacyDotNoteImportState

    init(
        modelContainer: ModelContainer,
        legacyImportSource: LegacyDotNoteImportSource? = nil,
        legacyImportState: LegacyDotNoteImportState = LegacyDotNoteImportState()
    ) {
        self.modelContainer = modelContainer
        self.legacyImportSource = legacyImportSource
        self.legacyImportState = legacyImportState
    }

    @MainActor
    func loadInitialSnapshot() async throws -> DotNoteStoreSnapshot {
        let context = ModelContext(modelContainer)
        try importLegacyDataIfNeeded(in: context)
        var snapshot = try loadSnapshot(in: context)
        snapshot.diagnostics = makeDiagnostics()
        return snapshot
    }

    @MainActor
    func addEntry(_ entry: DotNoteEntry) async throws -> DotNoteStoreSnapshot {
        let context = ModelContext(modelContainer)
        context.insert(DotNoteEntryRecord(entry: entry))
        try context.save()

        return try loadSnapshotWithDiagnostics(in: context)
    }

    @MainActor
    func updateEntry(_ entry: DotNoteEntry) async throws -> DotNoteStoreSnapshot {
        let context = ModelContext(modelContainer)

        if let record = try fetchEntryRecord(id: entry.id, in: context) {
            record.update(with: entry)
            try context.save()
        }

        return try loadSnapshotWithDiagnostics(in: context)
    }

    @MainActor
    func deleteEntry(id: DotNoteEntry.ID) async throws -> DotNoteStoreSnapshot {
        let context = ModelContext(modelContainer)

        if let record = try fetchEntryRecord(id: id, in: context) {
            context.delete(record)
            try context.save()
        }

        return try loadSnapshotWithDiagnostics(in: context)
    }

    @MainActor
    func updateSettings(_ settings: DotNoteSettings) async throws -> DotNoteStoreSnapshot {
        let context = ModelContext(modelContainer)

        if let record = try fetchSettingsRecord(in: context) {
            record.update(with: settings)
        } else {
            context.insert(DotNoteSettingsRecord(settings: settings))
        }
        try context.save()

        return try loadSnapshotWithDiagnostics(in: context)
    }

    @MainActor
    func deleteAllData() async throws -> DotNoteStoreSnapshot {
        let context = ModelContext(modelContainer)
        let entries = try context.fetch(FetchDescriptor<DotNoteEntryRecord>())
        let settings = try context.fetch(FetchDescriptor<DotNoteSettingsRecord>())

        for entry in entries {
            context.delete(entry)
        }
        for setting in settings {
            context.delete(setting)
        }
        try context.save()

        return try loadSnapshotWithDiagnostics(in: context)
    }

    @MainActor
    private func loadSnapshot(in context: ModelContext) throws -> DotNoteStoreSnapshot {
        let entryDescriptor = FetchDescriptor<DotNoteEntryRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let settingsDescriptor = FetchDescriptor<DotNoteSettingsRecord>()

        let entries = try context.fetch(entryDescriptor).map(DotNoteEntry.init(record:))
        let settings = try context.fetch(settingsDescriptor).first.map(DotNoteSettings.init(record:))

        return DotNoteStoreSnapshot(entries: entries, settings: settings)
    }

    @MainActor
    private func loadSnapshotWithDiagnostics(in context: ModelContext) throws -> DotNoteStoreSnapshot {
        var snapshot = try loadSnapshot(in: context)
        snapshot.diagnostics = makeDiagnostics()
        return snapshot
    }

    @MainActor
    private func fetchEntryRecord(id: DotNoteEntry.ID, in context: ModelContext) throws -> DotNoteEntryRecord? {
        var descriptor = FetchDescriptor<DotNoteEntryRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func fetchSettingsRecord(in context: ModelContext) throws -> DotNoteSettingsRecord? {
        var descriptor = FetchDescriptor<DotNoteSettingsRecord>()
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func importLegacyDataIfNeeded(in context: ModelContext) throws {
        guard !legacyImportState.didCompleteImport else { return }
        guard try hasNoSwiftDataRecords(in: context) else {
            legacyImportState.markImportCompleted()
            return
        }
        guard let legacyImportSource else { return }

        let legacySnapshot = try legacyImportSource.loadLegacySnapshot()
        guard !legacySnapshot.entries.isEmpty || legacySnapshot.settings != nil else {
            legacyImportState.markImportCompleted()
            return
        }

        for entry in legacySnapshot.entries {
            context.insert(DotNoteEntryRecord(entry: entry))
        }

        if let settings = legacySnapshot.settings {
            context.insert(DotNoteSettingsRecord(settings: settings))
        }

        try context.save()
        legacyImportState.markImportCompleted()
    }

    @MainActor
    private func hasNoSwiftDataRecords(in context: ModelContext) throws -> Bool {
        var entryDescriptor = FetchDescriptor<DotNoteEntryRecord>()
        var settingsDescriptor = FetchDescriptor<DotNoteSettingsRecord>()
        entryDescriptor.fetchLimit = 1
        settingsDescriptor.fetchLimit = 1

        return try context.fetch(entryDescriptor).isEmpty
            && context.fetch(settingsDescriptor).isEmpty
    }

    private func makeDiagnostics() -> DotNoteStoreDiagnostics {
        DotNoteStoreDiagnostics(
            hasLegacyImportSource: legacyImportSource != nil,
            legacyImportSourceDescription: legacyImportSource?.sourceDescription,
            legacyImportFileURL: legacyImportSource?.sourceFileURL,
            didCompleteLegacyImport: legacyImportState.didCompleteImport
        )
    }
}
