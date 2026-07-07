//
//  DotNoteRootView.swift
//  Orbit
//
//  Initial SwiftUI shell for the rebuild path.
//

import SwiftUI

struct DotNoteRootView: View {
    @ObservedObject var appModel: DotNoteAppModel
    @State private var editorMode: DotNoteEntryEditorMode?

    var body: some View {
        NavigationStack {
            DotNoteMigrationPreviewView(
                entries: appModel.entries,
                settings: appModel.settings,
                diagnostics: appModel.diagnostics,
                loadState: appModel.loadState,
                onSelectEntry: { entry in
                    editorMode = .edit(entry)
                },
                onDeleteEntries: { offsets in
                    deleteEntries(at: offsets)
                }
            )
                .navigationTitle("Dot Note")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editorMode = .create
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .accessibilityLabel("New note")
                    }
                }
                .sheet(item: $editorMode) { mode in
                    DotNoteEntryEditorView(mode: mode, isSaving: appModel.isSaving) { entry in
                        await appModel.updateEntry(entry)
                        editorMode = nil
                    } onCreate: { entry in
                        await appModel.addEntry(entry)
                        editorMode = nil
                    } onDelete: { id in
                        await appModel.deleteEntry(id: id)
                        editorMode = nil
                    }
                }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let ids = offsets.map { appModel.entries[$0].id }
        Task {
            for id in ids {
                await appModel.deleteEntry(id: id)
            }
        }
    }
}

private enum DotNoteEntryEditorMode: Identifiable {
    case create
    case edit(DotNoteEntry)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let entry):
            return entry.id.uuidString
        }
    }

    var entry: DotNoteEntry {
        switch self {
        case .create:
            return DotNoteEntry(kind: .memo)
        case .edit(let entry):
            return entry
        }
    }

    var isCreating: Bool {
        if case .create = self {
            return true
        }
        return false
    }
}

private struct DotNoteEntryEditorView: View {
    var mode: DotNoteEntryEditorMode
    var isSaving: Bool
    var onSave: (DotNoteEntry) async -> Void
    var onCreate: (DotNoteEntry) async -> Void
    var onDelete: (DotNoteEntry.ID) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var kind: DotNoteEntryKind
    @State private var createdAt: Date
    @State private var title = ""
    @State private var weather = ""
    @State private var memoBody = ""

    init(
        mode: DotNoteEntryEditorMode,
        isSaving: Bool,
        onSave: @escaping (DotNoteEntry) async -> Void,
        onCreate: @escaping (DotNoteEntry) async -> Void,
        onDelete: @escaping (DotNoteEntry.ID) async -> Void
    ) {
        let entry = mode.entry
        self.mode = mode
        self.isSaving = isSaving
        self.onSave = onSave
        self.onCreate = onCreate
        self.onDelete = onDelete
        _kind = State(initialValue: entry.kind)
        _createdAt = State(initialValue: entry.createdAt)
        _title = State(initialValue: entry.title)
        _weather = State(initialValue: entry.weather)
        _memoBody = State(initialValue: entry.body)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Kind", selection: $kind) {
                        ForEach(DotNoteEntryKind.allCases) { kind in
                            Text(kind.rawValue.capitalized)
                                .tag(kind)
                        }
                    }
                    DatePicker("Date", selection: $createdAt, displayedComponents: .date)
                }

                Section {
                    TextField("Title", text: $title)
                    TextField("Weather", text: $weather)
                    TextEditor(text: $memoBody)
                        .frame(minHeight: 160)
                }

                if !mode.isCreating {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await onDelete(mode.entry.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(isSaving)
                    }
                }
            }
            .navigationTitle(mode.isCreating ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let editedEntry = DotNoteEntry(
                                id: mode.entry.id,
                                kind: kind,
                                createdAt: createdAt,
                                title: title,
                                weather: weather,
                                body: memoBody,
                                textAlignment: mode.entry.textAlignment,
                                imageData: mode.entry.imageData
                            )
                            if mode.isCreating {
                                await onCreate(editedEntry)
                            } else {
                                await onSave(editedEntry)
                            }
                        }
                    }
                    .disabled(isSaving || memoBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#if DEBUG
struct DotNoteRootView_Previews: PreviewProvider {
    static var previews: some View {
        DotNoteRootView(appModel: DotNoteAppModel(
            store: InMemoryDotNoteStore(snapshot: DotNoteStoreSnapshot(
                entries: [
                    DotNoteEntry(kind: .diary, title: "Diary", weather: "Sunny", body: "A saved diary entry."),
                    DotNoteEntry(kind: .memo, body: "A quick memo."),
                    DotNoteEntry(kind: .drawing, title: "Drawing", body: "A drawing note.")
                ],
                settings: DotNoteSettings(bodyFontName: "NanumBarunGothic", bodyFontSize: 16)
            ))
        )
        )
    }
}
#endif
