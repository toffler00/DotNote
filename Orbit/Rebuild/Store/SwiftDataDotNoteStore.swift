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
    private func importLegacyDataIfNeeded(in context: ModelContext) throws {
        guard !legacyImportState.didCompleteImport else { return }
        guard try hasNoSwiftDataEntries(in: context) else {
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
    private func hasNoSwiftDataEntries(in context: ModelContext) throws -> Bool {
        var descriptor = FetchDescriptor<DotNoteEntryRecord>()
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).isEmpty
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
