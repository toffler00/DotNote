# Dot Note Rebuild Plan

This branch revives the existing App Store app by rebuilding the implementation with SwiftUI while preserving the app identity and user data.

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
- Persistence: SwiftData/Core Data for the long-term store, with a Realm import bridge for existing users
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
8. Next: restore real legacy data import by adding a maintained persistence dependency or a one-time importer.

## Migration Layer

The first migration files live under `Orbit/Rebuild/Migration`.

- `LegacyDotNoteSnapshots.swift` defines lightweight snapshots of the legacy Realm objects.
- `LegacyDotNoteMapper.swift` converts snapshots into the new domain models.
- `LegacyRealmStore.swift` reads the existing Realm database only when `RealmSwift` is available.

Legacy content mapping:

- `Content.type == "diary"` maps to `DotNoteEntryKind.diary`.
- `Content.type == "memo"` maps to `DotNoteEntryKind.memo`.
- `Content.type == "drawing"` maps to `DotNoteEntryKind.drawing`.
- Unknown content types currently fall back to `.diary`.

Legacy alignment mapping:

- `left`, `center`, and `right` map directly.
- Unknown alignment values fall back to `.left`.

Next, wire these files into the app target after the project is moved to a modern Swift toolchain setting. Until then, they remain source-controlled scaffolding and can be typechecked independently.

## Project Modernization Notes

The app target keeps `PRODUCT_BUNDLE_IDENTIFIER = io.orbit.orbit.prod`.

Initial project settings now use:

- iOS deployment target: `16.0`
- Swift language version: `5.0`

The deprecated Fabric run script build phase has been removed from the app target. The old Fabric and Crashlytics pods are still present for now and should be removed in a focused dependency cleanup step.

The SwiftUI shell lives under `Orbit/Rebuild/App`.

- `DotNoteApp.swift` is the current SwiftUI app entry point.
- `DotNoteRootView.swift` is the future SwiftUI root view.
- `DotNoteMigrationPreviewView.swift` is a temporary view for checking imported legacy entries.

Current build status:

- `xcodebuild -list -project Orbit.xcodeproj` succeeds.
- Independent typechecking for the rebuild domain and migration files succeeds.
- `xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO` succeeds after disconnecting the app target from CocoaPods and compiling only the SwiftUI rebuild sources.
- `pod install` succeeds with network access, but `xcodebuild -workspace Orbit.xcworkspace` still reports that the workspace is not a workspace file in this environment. Continue using the project build as the immediate diagnostic path while old pods are removed or replaced.

Legacy UIKit files are still present in the repository for reference, but they are no longer compiled by the app target. This keeps the production bundle ID and app target alive while giving the rebuild a clean SwiftUI build surface.
