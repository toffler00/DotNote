//
//  DotNoteApp.swift
//  Orbit
//
//  SwiftUI entry point for the rebuild target.
//

import SwiftUI
import SwiftData

@main
struct DotNoteApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var appModel: DotNoteAppModel

    init() {
        do {
            let isUITesting = ProcessInfo.processInfo.arguments.contains("--dotnote-ui-testing")
            let modelContainer = try DotNoteModelContainer.make(isStoredInMemoryOnly: isUITesting)
            self.modelContainer = modelContainer
            _appModel = StateObject(wrappedValue: DotNoteAppModel(
                store: SwiftDataDotNoteStore(
                    modelContainer: modelContainer,
                    legacyImportSource: isUITesting ? nil : LegacyDotNoteImportFactory.makeDefaultImportSource()
                )
            ))
        } catch {
            fatalError("Failed to create SwiftData model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DotNoteRootView(appModel: appModel)
                .task {
                    await appModel.load()
                }
                .modelContainer(modelContainer)
        }
    }
}
