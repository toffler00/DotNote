//
//  DotNoteRootView.swift
//  Orbit
//
//  Initial SwiftUI shell for the rebuild path.
//

import SwiftUI

struct DotNoteRootView: View {
    @ObservedObject var appModel: DotNoteAppModel

    var body: some View {
        NavigationStack {
            DotNoteMigrationPreviewView(
                entries: appModel.entries,
                settings: appModel.settings,
                loadState: appModel.loadState
            )
                .navigationTitle("Dot Note")
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
