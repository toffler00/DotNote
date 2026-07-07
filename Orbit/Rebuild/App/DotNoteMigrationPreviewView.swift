//
//  DotNoteMigrationPreviewView.swift
//  Orbit
//
//  Temporary SwiftUI view for validating imported legacy entries.
//

import SwiftUI

struct DotNoteMigrationPreviewView: View {
    var entries: [DotNoteEntry]
    var settings: DotNoteSettings?
    var diagnostics: DotNoteStoreDiagnostics
    var loadState: DotNoteAppModel.LoadState
    var onSelectEntry: (DotNoteEntry) -> Void = { _ in }
    var onDeleteEntries: (IndexSet) -> Void = { _ in }

    var body: some View {
        List {
            Section {
                LabeledContent("Load state", value: loadStateDescription)
                LabeledContent("Imported entries", value: "\(entries.count)")
                if let settings {
                    LabeledContent("Body font", value: settings.bodyFontName.isEmpty ? "Default" : settings.bodyFontName)
                    LabeledContent("Body size", value: "\(settings.bodyFontSize)")
                } else {
                    LabeledContent("Settings", value: "Not imported")
                }
            }

            Section("Import diagnostics") {
                LabeledContent("Legacy source", value: legacySourceDescription)
                LabeledContent("Import completed", value: diagnostics.didCompleteLegacyImport ? "Yes" : "No")
                LabeledContent("Realm file", value: legacyFileDescription)
            }

            Section("Entries") {
                if entries.isEmpty {
                    Label("No entries", systemImage: "doc.text.magnifyingglass")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entries) { entry in
                        Button {
                            onSelectEntry(entry)
                        } label: {
                            DotNoteEntryPreviewRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: onDeleteEntries)
                }
            }
        }
    }

    private var loadStateDescription: String {
        switch loadState {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading"
        case .loaded:
            return "Loaded"
        case .failed(let message):
            return message
        }
    }

    private var legacySourceDescription: String {
        guard diagnostics.hasLegacyImportSource else { return "Unavailable" }
        return diagnostics.legacyImportSourceDescription ?? "Available"
    }

    private var legacyFileDescription: String {
        diagnostics.legacyImportFileURL?.path ?? "Not found"
    }
}

private struct DotNoteEntryPreviewRow: View {
    var entry: DotNoteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.kind.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !entry.title.isEmpty {
                Text(entry.title)
                    .font(.headline)
            }

            if !entry.weather.isEmpty {
                Text(entry.weather)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !entry.body.isEmpty {
                Text(entry.body)
                    .font(.body)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}
