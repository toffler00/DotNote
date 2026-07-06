//
//  DotNoteModelContainer.swift
//  Orbit
//
//  Creates the SwiftData container used by the rebuild app.
//

import SwiftData

enum DotNoteModelContainer {
    static func make(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            DotNoteEntryRecord.self,
            DotNoteSettingsRecord.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

