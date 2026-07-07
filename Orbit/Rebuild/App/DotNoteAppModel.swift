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
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let entry = DotNoteEntry(
                kind: .memo,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                body: body.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            let snapshot = try await store.addEntry(entry)
            entries = snapshot.entries
            settings = snapshot.settings
            diagnostics = snapshot.diagnostics
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }
}
