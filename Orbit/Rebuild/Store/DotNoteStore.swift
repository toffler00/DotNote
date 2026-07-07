//
//  DotNoteStore.swift
//  Orbit
//
//  Storage boundary for the SwiftUI rebuild.
//

import Foundation

struct DotNoteStoreDiagnostics: Equatable {
    var hasLegacyImportSource: Bool
    var legacyImportSourceDescription: String?
    var legacyImportFileURL: URL?
    var didCompleteLegacyImport: Bool

    init(
        hasLegacyImportSource: Bool = false,
        legacyImportSourceDescription: String? = nil,
        legacyImportFileURL: URL? = nil,
        didCompleteLegacyImport: Bool = false
    ) {
        self.hasLegacyImportSource = hasLegacyImportSource
        self.legacyImportSourceDescription = legacyImportSourceDescription
        self.legacyImportFileURL = legacyImportFileURL
        self.didCompleteLegacyImport = didCompleteLegacyImport
    }
}

struct DotNoteStoreSnapshot: Equatable {
    var entries: [DotNoteEntry]
    var settings: DotNoteSettings?
    var diagnostics: DotNoteStoreDiagnostics

    init(
        entries: [DotNoteEntry] = [],
        settings: DotNoteSettings? = nil,
        diagnostics: DotNoteStoreDiagnostics = DotNoteStoreDiagnostics()
    ) {
        self.entries = entries
        self.settings = settings
        self.diagnostics = diagnostics
    }
}

protocol DotNoteStore {
    @MainActor
    func loadInitialSnapshot() async throws -> DotNoteStoreSnapshot

    @MainActor
    func addEntry(_ entry: DotNoteEntry) async throws -> DotNoteStoreSnapshot

    @MainActor
    func updateEntry(_ entry: DotNoteEntry) async throws -> DotNoteStoreSnapshot

    @MainActor
    func deleteEntry(id: DotNoteEntry.ID) async throws -> DotNoteStoreSnapshot
}
