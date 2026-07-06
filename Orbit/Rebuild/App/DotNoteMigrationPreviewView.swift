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
    var loadState: DotNoteAppModel.LoadState

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

            Section("Entries") {
                if entries.isEmpty {
                    Label("No entries", systemImage: "doc.text.magnifyingglass")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entries) { entry in
                        DotNoteEntryPreviewRow(entry: entry)
                    }
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
