//
//  DotNoteApp.swift
//  Orbit
//
//  SwiftUI entry point for the rebuild target.
//

import SwiftUI

@main
struct DotNoteApp: App {
    var body: some Scene {
        WindowGroup {
            DotNoteRootView(entries: [], settings: nil)
        }
    }
}
