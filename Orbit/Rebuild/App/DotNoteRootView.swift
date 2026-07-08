//
//  DotNoteRootView.swift
//  Orbit
//
//  Root coordinator for the SwiftUI rebuild.
//  Hosts the redesigned calendar-first home and routes entry editing.
//

import SwiftUI

struct DotNoteRootView: View {
    @ObservedObject var appModel: DotNoteAppModel
    @State private var editorMode: DotNoteEntryEditorMode?

    var body: some View {
        NavigationStack {
            CalendarHomeView(
                entries: appModel.entries,
                settings: appModel.settings,
                onCreate: { kind in editorMode = .create(kind) },
                onSelectEntry: { entry in editorMode = .edit(entry) },
                onOpenSettings: { /* Settings screen lands in a later milestone. */ }
            )
            .navigationBarHidden(true)
            .sheet(item: $editorMode) { mode in
                DotNoteEntryEditorView(mode: mode, settings: appModel.settings, isSaving: appModel.isSaving) { entry in
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
}

enum DotNoteEntryEditorMode: Identifiable {
    case create(DotNoteEntryKind)
    case edit(DotNoteEntry)

    var id: String {
        switch self {
        case .create(let kind):
            return "create-\(kind.rawValue)"
        case .edit(let entry):
            return entry.id.uuidString
        }
    }

    var entry: DotNoteEntry {
        switch self {
        case .create(let kind):
            return DotNoteEntry(kind: kind)
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

#if DEBUG
struct DotNoteRootView_Previews: PreviewProvider {
    static var previews: some View {
        DotNoteRootView(appModel: DotNoteAppModel(
            store: InMemoryDotNoteStore(snapshot: DotNoteStoreSnapshot(
                entries: [
                    DotNoteEntry(kind: .diary, title: "Diary", weather: "맑음", body: "A saved diary entry."),
                    DotNoteEntry(kind: .memo, body: "A quick memo."),
                    DotNoteEntry(kind: .drawing, title: "Drawing", body: "A drawing note.")
                ],
                settings: DotNoteSettings(bodyFontName: "barunGothic", bodyFontSize: 16)
            ))
        )
        )
    }
}
#endif
