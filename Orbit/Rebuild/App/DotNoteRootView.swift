//
//  DotNoteRootView.swift
//  Orbit
//
//  Initial SwiftUI shell for the rebuild path.
//

import SwiftUI

struct DotNoteRootView: View {
    var entries: [DotNoteEntry]
    var settings: DotNoteSettings?

    var body: some View {
        NavigationStack {
            DotNoteMigrationPreviewView(entries: entries, settings: settings)
                .navigationTitle("Dot Note")
        }
    }
}

#if DEBUG
struct DotNoteRootView_Previews: PreviewProvider {
    static var previews: some View {
        DotNoteRootView(
            entries: [
                DotNoteEntry(kind: .diary, title: "Diary", weather: "Sunny", body: "A saved diary entry."),
                DotNoteEntry(kind: .memo, body: "A quick memo."),
                DotNoteEntry(kind: .drawing, title: "Drawing", body: "A drawing note.")
            ],
            settings: DotNoteSettings(bodyFontName: "NanumBarunGothic", bodyFontSize: 16)
        )
    }
}
#endif
