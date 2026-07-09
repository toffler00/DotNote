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
- Current active UI: SwiftUI redesign is past the original Milestone 1 scaffold
  - `DotNoteTheme` tokens are in the app target.
  - Calendar-first home screen is active.
  - Typed diary/drawing/memo editors are active.
  - Settings, font picker, diary/memo/drawing collections, help/license
    destinations, drawing editor polish, and Set A app icon/launch screen assets
    are applied.
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
2. `docs/CURRENT_UI_BASELINE.md`
3. `docs/REDESIGN_WORKLOG.md`
4. `swift/HANDOFF_FOR_CLAUDE_CODE.md`
5. `docs/CLAUDE_UI_REDESIGN_HANDOFF.md`
6. `docs/legacy-ui-screenshots/README.md`
7. `REDESIGN_READINESS.md`
8. `REBUILD.md`

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
- UI smoke tests exist and have passed through the latest functional UI
  milestones:
  - Launch app
  - Open the expanded create row
  - Create/edit/delete memo
  - Open settings
  - Change body font
  - Open settings support destinations
  - Open diary/memo/drawing collection cards back into editors
- `docs/REDESIGN_WORKLOG.md` records the important build/crash lessons:
  - Do not reuse hand-authored pbxproj IDs; grep the exact 24-character ID
    before adding files.
  - `plutil -lint` only proves plist syntax, not Xcode object graph validity.
  - Bare `simctl launch` may crash because RealmSwift is not embedded/resolved
    the same way as the `xcodebuild test` environment.

## Current Verification Commands

Use these exact commands unless the available simulator changes. Realm was
updated for Xcode 26.5, so the previous RealmCore C++ workaround flag is no
longer required for the current package pins.

Dev build:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

Dev unit + UI tests:

```sh
xcodebuild test -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

Prod simulator build:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Prod -configuration Prod -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

## Next Recommended Work

Continue from the current Set A / SwiftUI redesign state, not the original
scaffold state.

Recommended next implementation unit:

1. Refine the current `CalendarHomeView` visually against the latest Set A brand
   tone.
2. Continue editor polish, especially diary and memo density/typography.
3. Continue Settings and collection polish.
4. Keep all create/edit/delete behavior routed through `DotNoteAppModel`.
5. Keep design values inside `DotNoteTheme.swift`.
6. Run `Orbit_Dev` build + tests before committing normal UI changes.

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
브랜치는 rebuild 이고, 먼저 docs/NEXT_SESSION_START.md, docs/DESIGN_HANDOFF_INDEX.md, docs/CURRENT_UI_BASELINE.md, docs/REDESIGN_WORKLOG.md, swift/HANDOFF_FOR_CLAUDE_CODE.md, REDESIGN_READINESS.md, REBUILD.md 를 읽어줘.
현재 SwiftUI 진입점은 DotNoteApp → DotNoteRootView → CalendarHomeView 이고, typed editors/settings/collections/Set A icon/launch screen까지 적용되어 있어.
다음은 현재 구조를 유지한 채 홈 화면과 에디터/설정의 시각 polish를 이어가줘.
저장/삭제/마이그레이션 로직은 건드리지 말고 DotNoteAppModel 경로만 사용해줘.
pbxproj 파일을 수정해야 하면 기존 24자리 ID와 충돌하지 않는지 반드시 grep으로 확인해줘.
작업 후 일반 UI 변경은 Orbit_Dev 테스트, 리소스/번들 변경은 Orbit_Dev 빌드와 Orbit_Prod 빌드를 확인하고 적절한 시점에 커밋해줘.
```
