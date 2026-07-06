//
//  LegacyDotNoteImportState.swift
//  Orbit
//
//  Tracks whether the one-time legacy import has completed.
//

import Foundation

struct LegacyDotNoteImportState {
    private let defaults: UserDefaults
    private let didCompleteImportKey = "io.orbit.dotnote.rebuild.didCompleteLegacyImport"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var didCompleteImport: Bool {
        defaults.bool(forKey: didCompleteImportKey)
    }

    func markImportCompleted() {
        defaults.set(true, forKey: didCompleteImportKey)
    }
}

