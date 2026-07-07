# Claude UI Redesign Handoff

This document summarizes the rebuild state for a Claude Code design pass.
The goal is to redesign the app visually and interaction-wise while preserving
the current rebuilt structure, app identity, and data-migration direction.

## Current Goal

Revive the legacy Dot Note iOS app as a modern SwiftUI app.

The production App Store identity must stay intact:

- App target: `Orbit`
- Production bundle ID: `io.orbit.orbit.prod`
- Product name in Prod: `Orbit.app`
- Dev product name: `OrbitDEV.app`
- Branch: `rebuild`

The old UIKit app is now reference material. The active app path is SwiftUI.

## What Has Already Changed

- The app now launches through SwiftUI `@main` in `Orbit/Rebuild/App/DotNoteApp.swift`.
- The storyboard launch path is no longer active for the app runtime.
- SwiftData is the selected long-term persistence layer.
- Realm remains only as a temporary read-only legacy import bridge.
- CocoaPods, Podfile, Podfile.lock, and the checked-in `Pods/` vendor tree have been removed from the active build path.
- RealmSwift is connected through Swift Package Manager only to support legacy import.
- A smoke UI test now verifies the current SwiftUI shell can create, edit, and delete a memo.

Recent important commits:

- `779882a Add SwiftData entry editing`
- `2c5b31b Remove CocoaPods build integration`
- `69b5298 Remove checked-in Pods vendor tree`
- `f93d468 Add SwiftUI smoke UI test`

## Current SwiftUI/Rebuild Files

Use these files as the modern structure:

- `Orbit/Rebuild/App/DotNoteApp.swift`
- `Orbit/Rebuild/App/DotNoteAppModel.swift`
- `Orbit/Rebuild/App/DotNoteRootView.swift`
- `Orbit/Rebuild/App/DotNoteMigrationPreviewView.swift`
- `Orbit/Rebuild/Domain/DotNoteModels.swift`
- `Orbit/Rebuild/Store/DotNoteStore.swift`
- `Orbit/Rebuild/Store/SwiftDataDotNoteStore.swift`
- `Orbit/Rebuild/Store/SwiftDataDotNoteModels.swift`
- `Orbit/Rebuild/Migration/*`

Current UI status:

- The active UI is still a scaffold.
- It can show import diagnostics and entries.
- It can create, edit, and delete entries through a sheet.
- This UI is not the final product design.

## Design Guardrails

Read `REDESIGN_READINESS.md` before changing UI.

Most important rules:

- Keep storage, migration, filtering, and networking logic out of SwiftUI views.
- Route app behavior through `DotNoteAppModel` and `DotNoteStore`.
- Persist semantic values, not visual styling details.
- Do not hardcode final colors, spacing, typography, or design tokens into the data layer.
- The redesign should be able to change mostly View files.

## Legacy UI Reference Files

The old UIKit code remains in the repository for reference only. Do not rebuild
new UI by directly depending on these controllers.

Primary legacy screens:

- Main calendar/list: `Orbit/ListViewController.swift`
- Diary write screen: `Orbit/WriteViewController.swift`
- Memo overlay: `Orbit/MemoViewController.swift`, `Orbit/BackGroundViewController.swift`
- Diary detail: `Orbit/DiaryViewController.swift`
- Drawing diary: `Orbit/DrawingDiaryViewController.swift`, `Orbit/DrawingView.swift`
- Photos: `Orbit/PhotosViewController.swift`, `Orbit/PhotoCollectionView.swift`
- Options/settings: `Orbit/Option/OptionsViewController.swift`
- Theme settings: `Orbit/Option/ThemeSettingViewController.swift`
- Diary collection: `Orbit/Option/DiaryCollectionViewController.swift`
- Memo collection: `Orbit/Option/MemoCollectionTableView.swift`
- Tutorial: `Orbit/Option/PageMasterVC.swift`, `Orbit/Option/PageContentVC.swift`

Storyboard references:

- `Orbit/StoryBoard/Base.lproj/Main.storyboard`
- `Orbit/StoryBoard/TutorialPageView.storyboard`
- `Orbit/Base.lproj/LaunchScreen.storyboard`

Important legacy visual cues:

- Warm off-white/yellow background: commonly `UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)`.
- Large navigation title `Dot Note`.
- Calendar-first main screen with list below.
- Floating expandable create actions for diary, memo, and drawing.
- Custom Korean fonts under `Orbit/*.ttf` and `Orbit/*.otf`.
- Weather, date, font, alignment, memo, drawing, camera, and settings icons in `Orbit/Assets.xcassets`.

## Current Verification Commands

Build Dev:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO
```

Run unit tests plus SwiftUI smoke UI test:

```sh
xcodebuild test -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO
```

Build Prod:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Prod -configuration Prod -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO
```

Known current verified status:

- `Orbit_Dev` build succeeds.
- `Orbit_Dev` tests succeed with 9 unit tests, 1 skipped external Realm fixture test, and 1 UI smoke test.
- `Orbit_Prod` simulator build succeeds.

## UI Test Mode

The UI test launches the app with:

```sh
--dotnote-ui-testing
```

This makes `DotNoteApp` use an in-memory SwiftData container and disables the
legacy Realm import source. Keep this mode when adding UI tests so tests do not
depend on local user data.

Current UI test:

- `OrbitUITests/OrbitUITests.swift`
- Verifies: launch, create memo, edit memo, delete memo.

## Open Items

- Real legacy `.realm` file has not been provided yet.
- The external Realm fixture test remains skipped until a real file is available.
- The current SwiftUI UI is only a rebuild scaffold.
- Legacy UI screenshots still need to be captured for redesign reference.

## Recommended Next UI Work

1. Capture or reconstruct old UI references. See `docs/LEGACY_UI_SCREENSHOT_PLAN.md`.
2. Decide the modern product structure while preserving the old app mental model:
   calendar/list first, quick creation, diary/memo/drawing entry types.
3. Replace the temporary `DotNoteMigrationPreviewView` root with a real main screen.
4. Build reusable SwiftUI components for:
   - Month calendar strip/grid
   - Entry list row/card
   - Entry editor
   - Type picker: diary, memo, drawing
   - Weather/date controls
5. Keep updating `OrbitUITests` as product flows replace scaffold flows.
