# Dot Note Rebuild Plan

This branch revives the existing App Store app by rebuilding the implementation with SwiftUI while preserving the app identity and user data.

> **Redesign guardrails:** A Claude-driven design pass will follow this
> modernization. The current work is not a design task, but some choices here
> affect the future redesign's freedom. Follow the guardrails in
> [`REDESIGN_READINESS.md`](REDESIGN_READINESS.md) while working — mainly: keep
> logic out of Views, and persist semantic values rather than presentation
> values.

## Non-negotiables

- Keep the production bundle identifier: `io.orbit.orbit.prod`.
- Preserve access to the existing app container so installed users can keep their local data after an App Store update.
- Treat the current UIKit code as legacy reference and migration source, not as the long-term implementation.
- Do not remove the legacy Realm models until data migration is implemented and verified.
- Remove deprecated services and libraries before shipping, especially Fabric and the legacy Crashlytics SDK.

## Current Legacy Baseline

- App target: `Orbit`
- App display name: `Dot Note`
- Production bundle ID: `io.orbit.orbit.prod`
- Main storage: Realm models in `Orbit/DBModel.swift`
- UI stack: UIKit view controllers, storyboard, and programmatic layout
- Dependency manager: CocoaPods
- Swift version in project settings: Swift 4.2
- Legacy minimum iOS target: iOS 11.x

## Rebuild Strategy

1. Keep the existing app target and production bundle ID.
2. Introduce a new SwiftUI application shell inside the existing target.
3. Isolate legacy storage behind a migration layer.
4. Rebuild screens in SwiftUI feature by feature.
5. Replace old dependencies with modern Apple frameworks or maintained Swift packages.

## Proposed Modern Stack

- UI: SwiftUI
- App lifecycle: SwiftUI `@main App`
- Persistence: SwiftData for the long-term store, with a Realm import bridge for existing users
- Drawing: PencilKit
- Networking: `URLSession` with async/await
- Logging: `OSLog`
- Crash reporting: Firebase Crashlytics, only if still needed
- Package management: Swift Package Manager where third-party packages remain necessary

## Dependency Direction

- Remove: Fabric, legacy Crashlytics SDK, EFMarkdown, ExpandableButton.
- Prefer replacing: Alamofire, NXDrawKit, SwiftyBeaver.
- Temporarily keep or bridge: RealmSwift, RSKImageCropper.
- Re-evaluate: JTAppleCalendar, because a SwiftUI calendar may be simpler and safer.

## First Checkpoints

1. Done: confirm `rebuild` branch starts from a clean legacy baseline.
2. Done: preserve `io.orbit.orbit.prod` in the production configuration.
3. Done: add the SwiftUI rebuild source area without deleting legacy code.
4. Done: define domain models that are independent of Realm.
5. Done: add a legacy Realm import path before switching storage permanently.
6. Done: add a SwiftUI shell without switching the app launch path away from the storyboard.
7. Done: switch the app launch path away from the storyboard by using a SwiftUI `@main` entry point.
8. Done: add the first SwiftData-backed store boundary.
9. Done: add the one-time import boundary for legacy Realm data.
10. Done: reconnect a maintained Realm dependency so the import source can read existing app data.
11. Done: add a fixture-style unit test for the Realm-to-SwiftData import boundary.
12. Next: run the new unit test with Simulator access and then verify against a real legacy Realm file.

## Migration Layer

The first migration files live under `Orbit/Rebuild/Migration`.

- `LegacyDotNoteSnapshots.swift` defines lightweight snapshots of the legacy Realm objects.
- `LegacyDotNoteMapper.swift` converts snapshots into the new domain models.
- `LegacyRealmStore.swift` reads the existing Realm database only when `RealmSwift` is available.
- `LegacyRealmModels.swift` defines the minimal legacy Realm object schema used only by the importer.
- `LegacyDotNoteImportSource.swift` defines the boundary used by the new SwiftData store.
- `LegacyDotNoteImportState.swift` tracks whether the one-time import has completed.
- `LegacyDotNoteImportFactory.swift` activates the Realm import source only when `RealmSwift` is available.

Legacy content mapping:

- `Content.type == "diary"` maps to `DotNoteEntryKind.diary`.
- `Content.type == "memo"` maps to `DotNoteEntryKind.memo`.
- `Content.type == "drawing"` maps to `DotNoteEntryKind.drawing`.
- Unknown content types currently fall back to `.diary`.

Legacy alignment mapping:

- `left`, `center`, and `right` map directly.
- Unknown alignment values fall back to `.left`.

The import source is now wired into the app target through Swift Package Manager's `RealmSwift` package. Realm is still treated as a legacy read-only dependency, not as the app's long-term database.

## Project Modernization Notes

The app target keeps `PRODUCT_BUNDLE_IDENTIFIER = io.orbit.orbit.prod`.

Initial project settings now use:

- iOS deployment target: `17.0`
- Swift language version: `5.0`

The deprecated Fabric run script build phase has been removed from the app target. The old Fabric and Crashlytics pods are still present for now and should be removed in a focused dependency cleanup step.

Swift Package Manager dependencies now include:

- `RealmSwift` 10.54.6
- `realm-core` 14.14.0, resolved transitively by RealmSwift

The SwiftUI shell lives under `Orbit/Rebuild/App`.

- `DotNoteApp.swift` is the current SwiftUI app entry point.
- `DotNoteAppModel.swift` owns the root screen state and async loading flow.
- `DotNoteRootView.swift` is the future SwiftUI root view.
- `DotNoteMigrationPreviewView.swift` is a temporary view for checking imported legacy entries.

The first app data boundary lives under `Orbit/Rebuild/Store`.

- `DotNoteStore.swift` defines the storage protocol that SwiftUI views depend on.
- `InMemoryDotNoteStore.swift` keeps the rebuild shell runnable while the real importer is being wired.
- `SwiftDataDotNoteModels.swift` defines the new persistent records.
- `SwiftDataDotNoteMapper.swift` converts between persistent records and rebuild-domain models.
- `DotNoteModelContainer.swift` creates the SwiftData `ModelContainer`.
- `SwiftDataDotNoteStore.swift` is the first permanent store implementation.

SwiftData is now the selected long-term persistence layer. Realm remains a legacy read source for one-time import only.

On app startup, `SwiftDataDotNoteStore` checks whether SwiftData already has entries and whether the legacy import completion flag has been set. If SwiftData is empty and a legacy import source is available, it imports legacy entries/settings once, saves them into SwiftData, and records completion in `UserDefaults`.

Current build status:

- `xcodebuild -list -project Orbit.xcodeproj` succeeds.
- Independent typechecking for the rebuild domain and migration files succeeds.
- `xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO` succeeds after disconnecting the app target from CocoaPods and compiling only the SwiftUI rebuild sources.
- With RealmSwift connected, the current Xcode/SDK toolchain requires `OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization` while compiling RealmCore. The verified command is `xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO`.
- `OrbitTests/LegacyRealmImportTests.swift` creates a temporary Realm file and verifies that `LegacyRealmStore` maps legacy content/settings into the rebuild snapshot. Running `xcodebuild test` still needs Simulator access outside the current sandbox, so the test has been added but not executed in this session.
- `pod install` succeeds with network access, but `xcodebuild -workspace Orbit.xcworkspace` still reports that the workspace is not a workspace file in this environment. Continue using the project build as the immediate diagnostic path while old pods are removed or replaced.

Legacy UIKit files are still present in the repository for reference, but they are no longer compiled by the app target. This keeps the production bundle ID and app target alive while giving the rebuild a clean SwiftUI build surface.
