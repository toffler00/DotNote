//
//  DotNoteRootView.swift
//  Orbit
//
//  Initial SwiftUI shell for the rebuild path.
//

import SwiftUI

struct DotNoteRootView: View {
    @ObservedObject var appModel: DotNoteAppModel
    @State private var isShowingMemoComposer = false

    var body: some View {
        NavigationStack {
            DotNoteMigrationPreviewView(
                entries: appModel.entries,
                settings: appModel.settings,
                diagnostics: appModel.diagnostics,
                loadState: appModel.loadState
            )
                .navigationTitle("Dot Note")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingMemoComposer = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .accessibilityLabel("New memo")
                    }
                }
                .sheet(isPresented: $isShowingMemoComposer) {
                    DotNoteMemoComposerView(isSaving: appModel.isSaving) { title, body in
                        await appModel.addMemo(title: title, body: body)
                        isShowingMemoComposer = false
                    }
                }
        }
    }
}

private struct DotNoteMemoComposerView: View {
    var isSaving: Bool
    var onSave: (String, String) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var memoBody = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $memoBody)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("New Memo")
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
                            await onSave(title, memoBody)
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
