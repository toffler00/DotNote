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
    @State private var isShowingSettings = false

    var body: some View {
        ZStack {
            NavigationStack {
                CalendarHomeView(
                    entries: appModel.entries,
                    settings: appModel.settings,
                    onCreate: { kind in editorMode = .create(kind) },
                    onSelectEntry: { entry in editorMode = .edit(entry) },
                    onOpenSettings: { isShowingSettings = true }
                )
                .navigationBarHidden(true)
            }
            .disabled(editorMode != nil || isShowingSettings)

            if let mode = editorMode {
                DotNoteEntryEditorView(mode: mode, settings: appModel.settings, isSaving: appModel.isSaving) { entry in
                    await appModel.updateEntry(entry)
                    editorMode = nil
                } onCreate: { entry in
                    await appModel.addEntry(entry)
                    editorMode = nil
                } onDelete: { id in
                    await appModel.deleteEntry(id: id)
                    editorMode = nil
                } onCancel: {
                    editorMode = nil
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
            }

            if isShowingSettings {
                DotNoteSettingsView(
                    settings: appModel.settings,
                    entries: appModel.entries,
                    isSaving: appModel.isSaving,
                    onUpdateSettings: { settings in
                        await appModel.updateSettings(settings)
                    },
                    onDeleteAllData: {
                        await appModel.deleteAllData()
                    },
                    onSelectEntry: { entry in
                        isShowingSettings = false
                        editorMode = .edit(entry)
                    },
                    onClose: {
                        isShowingSettings = false
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(2)
            }
        }
        .preferredColorScheme(appModel.settings?.appearanceMode.preferredColorScheme)
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
@MainActor
enum DotNotePreviewData {
    static let entries: [DotNoteEntry] = [
        DotNoteEntry(
            kind: .diary,
            createdAt: Date(),
            title: "여름 일기",
            weather: "맑음",
            body: "햇빛이 오래 남아 있는 하루.",
            textAlignment: .left
        ),
        DotNoteEntry(
            kind: .memo,
            createdAt: Date().addingTimeInterval(-3600),
            body: "장보기: 커피, 우유, 노트"
        ),
        DotNoteEntry(
            kind: .drawing,
            createdAt: Date().addingTimeInterval(-7200),
            title: "스케치",
            weather: "구름조금",
            body: "사진 위에 선을 더해보기."
        )
    ]

    static let settings = DotNoteSettings(
        bodyFontName: DotNoteFontTheme.barunGothic.rawValue,
        bodyFontSize: 16
    )

    static func appModel(appearanceMode: DotNoteAppearanceMode = .system) -> DotNoteAppModel {
        var settings = Self.settings
        settings.appearanceMode = appearanceMode
        return DotNoteAppModel(
            store: InMemoryDotNoteStore(snapshot: DotNoteStoreSnapshot(entries: entries, settings: settings))
        )
    }
}

struct DotNoteRootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DotNoteRootView(appModel: DotNotePreviewData.appModel(appearanceMode: .light))
                .previewDisplayName("Root Light")
            DotNoteRootView(appModel: DotNotePreviewData.appModel(appearanceMode: .dark))
                .previewDisplayName("Root Dark")
        }
    }
}
#endif

private extension DotNoteAppearanceMode {
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
