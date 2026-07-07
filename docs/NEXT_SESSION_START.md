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
- Current active UI: SwiftUI scaffold, not final product UI
- Working tree at handoff: clean

Recent relevant commits:

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
2. `docs/CLAUDE_UI_REDESIGN_HANDOFF.md`
3. `docs/legacy-ui-screenshots/README.md`
4. `REDESIGN_READINESS.md`
5. `REBUILD.md`

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
- UI smoke test exists and passes:
  - Launch app
  - Create memo
  - Edit memo
  - Delete memo

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

Do not jump straight into heavy styling. First replace the temporary scaffold
with a real product screen structure that can later be visually redesigned.

Recommended first implementation unit:

1. Add a SwiftUI main screen file, e.g. `Orbit/Rebuild/App/DotNoteMainView.swift`.
2. Keep `DotNoteRootView` as the navigation/root coordinator.
3. Move the current migration diagnostics into a secondary/debug section or
   separate temporary view.
4. Build a calendar-first main layout based on the old app:
   - Large `Dot Note` title
   - Month header
   - Weekday row
   - Month grid
   - Expandable create action row: memo, drawing diary, diary
   - Entry list below the calendar
5. Keep all behavior routed through `DotNoteAppModel`.
6. Update `OrbitUITests` to keep covering create/edit/delete after the root UI
   changes.

Keep the first UI pass structurally faithful, not visually final:

- Use system colors or a very thin local `DotNoteTheme`.
- Do not hardcode final brand tokens into models or store.
- Do not create a full component library yet.
- Do not migrate behavior into SwiftUI view bodies.

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
브랜치는 rebuild 이고, 먼저 docs/NEXT_SESSION_START.md, docs/DESIGN_HANDOFF_INDEX.md, REDESIGN_READINESS.md, REBUILD.md 를 읽어줘.
그 다음 추천된 첫 UI 작업 단위대로 SwiftUI 메인 화면 구조를 시작해줘.
현재 구조와 테스트는 유지하고, DotNoteRootView 를 coordinator 로 두면서 DotNoteMainView 를 추가해 calendar-first 홈 구조를 만들고 OrbitUITests 도 그 흐름에 맞게 갱신해줘.
작업 후 Orbit_Dev 테스트와 Orbit_Prod 빌드를 확인하고 적절한 시점에 커밋해줘.
```
