//
//  DotNoteAppModel.swift
//  Orbit
//
//  App-level state for the SwiftUI rebuild.
//

import Foundation

@MainActor
final class DotNoteAppModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var entries: [DotNoteEntry] = []
    @Published private(set) var settings: DotNoteSettings?
    @Published private(set) var diagnostics: DotNoteStoreDiagnostics = DotNoteStoreDiagnostics()
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var isSaving: Bool = false

    private let store: DotNoteStore

    init(store: DotNoteStore) {
        self.store = store
    }

    func load() async {
        guard loadState != .loading else { return }

        loadState = .loading

        do {
            let snapshot = try await store.loadInitialSnapshot()
            entries = snapshot.entries
            settings = snapshot.settings
            diagnostics = snapshot.diagnostics
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func addMemo(title: String, body: String) async {
        await addEntry(DotNoteEntry(kind: .memo, title: title, body: body))
    }

    func addEntry(_ entry: DotNoteEntry) async {
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let snapshot = try await store.addEntry(entry.trimmedTextFields())
            apply(snapshot: snapshot)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func updateEntry(_ entry: DotNoteEntry) async {
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let snapshot = try await store.updateEntry(entry.trimmedTextFields())
            apply(snapshot: snapshot)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func deleteEntry(id: DotNoteEntry.ID) async {
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let snapshot = try await store.deleteEntry(id: id)
            apply(snapshot: snapshot)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func updateSettings(_ settings: DotNoteSettings) async {
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let snapshot = try await store.updateSettings(settings)
            apply(snapshot: snapshot)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func deleteAllData() async {
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let snapshot = try await store.deleteAllData()
            apply(snapshot: snapshot)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private func apply(snapshot: DotNoteStoreSnapshot) {
        entries = snapshot.entries
        settings = snapshot.settings
        diagnostics = snapshot.diagnostics
        loadState = .loaded
    }
}

private extension DotNoteEntry {
    func trimmedTextFields() -> DotNoteEntry {
        DotNoteEntry(
            id: id,
            kind: kind,
            createdAt: createdAt,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            weather: weather.trimmingCharacters(in: .whitespacesAndNewlines),
            body: body.trimmingCharacters(in: .whitespacesAndNewlines),
            textAlignment: textAlignment,
            imageData: imageData
        )
    }
}
