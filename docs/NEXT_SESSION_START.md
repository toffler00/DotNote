# Next Session Start

This is the handoff note for continuing Dot Note after the weekly usage reset.
Start a fresh session from this file.

## Repository State

- Repo: `/Users/toffler/DotNote`
- Branch: `rebuild`
- App target: `Orbit`
- Production bundle ID: `io.orbit.orbit.prod`
- Long-term UI: SwiftUI
- Long-term persistence: SwiftData
- Legacy data import: read-only Realm bridge through SPM `RealmSwift`
- Current active UI: SwiftUI redesign Milestone 1 applied
  - `DotNoteTheme` tokens are in the app target.
  - Calendar-first home screen is active.
  - Interim `Form` editor is still used and should be replaced next.
- Working tree at handoff: verify with `git status`; `swift/` may contain
  external Claude design source files that are reference material unless
  intentionally added.

Recent relevant commits:

- `5bdd1ab Add redesign worklog for milestone 1`
- `addbf55 Redesign home screen with design tokens (milestone 1)`
- `925006d Add design handoff index for redesign pass`
- `f85f037 Add legacy UI capture reference for redesign handoff`
- `229c372 Document UI redesign handoff`
- `f93d468 Add SwiftUI smoke UI test`
- `69b5298 Remove checked-in Pods vendor tree`
- `2c5b31b Remove CocoaPods build integration`
- `779882a Add SwiftData entry editing`
- `7e8fe59 Add SwiftData memo write path`

## Read First

Read these in order:

1. `docs/DESIGN_HANDOFF_INDEX.md`
2. `docs/REDESIGN_WORKLOG.md`
3. `swift/HANDOFF_FOR_CLAUDE_CODE.md`
4. `docs/CLAUDE_UI_REDESIGN_HANDOFF.md`
5. `docs/legacy-ui-screenshots/README.md`
6. `REDESIGN_READINESS.md`
7. `REBUILD.md`

Primary visual references:

- `docs/legacy-ui-screenshots/01-main-calendar-collapsed.png`
- `docs/legacy-ui-screenshots/02-main-calendar-actions-expanded.png`
- `docs/legacy-ui-screenshots/03-write-diary.png`
- `docs/legacy-ui-screenshots/04-write-drawing-diary.png`
- `docs/legacy-ui-screenshots/05-write-memo.png`
- `docs/legacy-ui-screenshots/06-settings.png`
- `docs/legacy-ui-recordings/dotnote-walkthrough.mp4`

## What Is Already Done

- SwiftUI `@main` app entry exists.
- SwiftData store boundary exists.
- Realm-to-SwiftData import boundary exists.
- CocoaPods build integration and checked-in Pods vendor tree are removed.
- Dev/Prod schemes are verified:
  - Dev builds `OrbitDEV.app`
  - Prod builds `Orbit.app`
  - Both preserve `io.orbit.orbit.prod`
- UI smoke test exists and passed after Milestone 1:
  - Launch app
  - Open the expanded create row
  - Create memo
  - Edit memo
  - Delete memo
- `docs/REDESIGN_WORKLOG.md` records the important build/crash lessons:
  - Do not reuse hand-authored pbxproj IDs; grep the exact 24-character ID
    before adding files.
  - `plutil -lint` only proves plist syntax, not Xcode object graph validity.
  - Bare `simctl launch` may crash because RealmSwift is not embedded/resolved
    the same way as the `xcodebuild test` environment.

## Current Verification Commands

Use these exact commands unless the available simulator changes.

Dev build:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO
```

Dev unit + UI tests:

```sh
xcodebuild test -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO
```

Prod simulator build:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Prod -configuration Prod -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization CODE_SIGNING_ALLOWED=NO
```

Note: RealmCore currently needs `OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization`
with this Xcode/SDK combination.

## Next Recommended Work

Continue from the post-Milestone 1 state, not the original scaffold state.

Recommended next implementation unit:

1. Replace the interim `Form` editor with typed editors:
   - `DiaryEditorView`
   - `DrawingEditorView`
   - `MemoOverlayView`
   - shared `WeatherPicker`
2. Keep all create/edit/delete behavior routed through `DotNoteAppModel`.
3. Keep design values inside `DotNoteTheme.swift`.
4. Update `OrbitUITests` for the typed editor flow.
5. Run `Orbit_Dev` build + tests before committing.

## Design Direction From Legacy Captures

Preserve these as baseline cues unless the user explicitly changes direction:

- Calendar-first home screen.
- Warm ivory paper background (`#FFFFF0`).
- Warm near-black ink color around `#2F2422`.
- Dotted/stippled display treatment for the `Dot Note` wordmark and screen titles.
- Expandable create action row rather than a floating action button.
- Three entry types:
  - memo
  - drawing diary
  - diary
- Diary and drawing diary have richer editors than memo.
- Memo is a light overlay/card interaction in the old app.

## Open Risks / Pending Input

- A real legacy `.realm` file is still needed to verify migration against real user data.
- The current SwiftUI UI is a scaffold; product screens are not complete.
- The old UIKit files are reference only and are no longer compiled into the app.
- Do not remove legacy Realm models until real migration verification is done.

## Suggested First Prompt For New Session

Use this as the first message in the fresh session:

```text
DotNote 프로젝트를 /Users/toffler/DotNote 에서 이어서 진행해줘.
브랜치는 rebuild 이고, 먼저 docs/NEXT_SESSION_START.md, docs/DESIGN_HANDOFF_INDEX.md, docs/REDESIGN_WORKLOG.md, swift/HANDOFF_FOR_CLAUDE_CODE.md, REDESIGN_READINESS.md, REBUILD.md 를 읽어줘.
Milestone 1은 이미 적용되어 있으니 다음은 typed editor UI(DiaryEditorView, DrawingEditorView, MemoOverlayView, WeatherPicker)를 SwiftUI로 진행해줘.
저장/삭제/마이그레이션 로직은 건드리지 말고 DotNoteAppModel 경로만 사용해줘.
pbxproj 파일을 수정해야 하면 기존 24자리 ID와 충돌하지 않는지 반드시 grep으로 확인해줘.
작업 후 Orbit_Dev 테스트와 Orbit_Prod 빌드를 확인하고 적절한 시점에 커밋해줘.
```
