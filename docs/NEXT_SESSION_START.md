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
  - Drawing editor supports photo import plus in-canvas photo placement
    adjustment before save.
  - Drawing editor color picker has a custom popover with preset swatches and
    HSB sliders.
  - Drawing editor pen width uses the existing slider UX, with a compact toolbar
    footprint for mobile.
  - Diary/drawing weather rows and save buttons have been tightened for mobile
    layout.
  - Settings includes persisted appearance mode (`system`, `light`, `dark`).
  - Legacy Realm -> SwiftData migration has synthetic Realm and SwiftData
    import-flow unit coverage.
- Working tree at handoff: verify with `git status`; `swift/` may contain
  external Claude design source files that are reference material unless
  intentionally added.

Recent relevant commits:

- `c6e0075 Expand editor weather picker layout`
- `c6edccf Refine drawing editor toolbar layout`
- `e6ae787 Constrain editor save buttons`
- `7c585c9 Restore drawing width slider`
- `f722422 Add custom drawing color picker`
- `7b7018f Polish drawing toolbar selection controls`
- `0e42bd4 Guard drawing photo clear during pen input`
- `b91b0aa Document photo e2e verification, dark-mode pass, and legacy reorg`
- `9c02495 Relocate legacy UIKit source into Orbit/Legacy/`
- `b91e681 Validate SwiftData legacy import flow`
- `a00a3f2 Constrain drawing editor toolbar layout`
- `0836434 Embed RealmSwift framework in app bundle`
- `74cdd0e Add drawing photo placement controls`
- `2009a9c Add appearance mode setting and previews`
- `e766dac Document settings header consistency fix; sync baseline status`
- `b004a70 Unify settings sub-screen headers; remove destructive-title string check`
- `bb8577b Polish editor content hierarchy; add photo import to drawing canvas`
- `7f6e05e Fix mismatched PostScript names for 4 custom fonts`
- `efbcfae Replace app icon and launch screen assets`

## Read First

Read these in order:

1. `docs/DESIGN_HANDOFF_INDEX.md`
2. `docs/CLAUDE_CODE_CONTINUATION_BRIEF.md`
3. `docs/CURRENT_UI_BASELINE.md`
4. `docs/REDESIGN_WORKLOG.md`
5. `swift/HANDOFF_FOR_CLAUDE_CODE.md`
6. `docs/CLAUDE_UI_REDESIGN_HANDOFF.md`
7. `docs/legacy-ui-screenshots/README.md`
8. `REDESIGN_READINESS.md`
9. `REBUILD.md`

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
  - `RealmSwift.framework` must be embedded in the app bundle. The app target
    now has an `Embed Frameworks` phase for RealmSwift.
  - Bare `simctl launch` is usable again after the RealmSwift embed fix.

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

1. Continue small editor UI polish only where the user points out real mobile
   layout issues. The current diary/drawing editor mobile layout has passed a
   quick `Orbit_Dev` build + full test check.
2. For drawing photo import, keep the current in-canvas placement UX. The user
   decided not to recreate a separate legacy-style crop screen.
3. Migration is now treated as regression safety because there is no old Realm
   backup available. Keep the synthetic Realm and SwiftData import-flow tests
   passing; do not block progress on a real `default.realm` fixture unless one
   appears later.
4. Keep all create/edit/delete behavior routed through `DotNoteAppModel`.
5. Keep design values inside `DotNoteTheme.swift`.
6. Run `Orbit_Dev` build + tests before committing normal UI changes. Run
   `Orbit_Prod` build as well for resource, bundle, launch screen, scheme, or
   release-oriented changes.

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

- There is no real legacy `.realm` backup available. Synthetic Realm and
  SwiftData import-flow unit tests are the migration safety net for now.
- The SwiftUI UI is functional, but real-device visual QA is still valuable
  after each editor layout change.
- Old UIKit files have been moved to `Orbit/Legacy/` as reference-only source,
  with active resource exceptions documented in `docs/REDESIGN_WORKLOG.md`.
- Do not remove legacy Realm models until real migration verification is done.

## Suggested First Prompt For New Session

Use this as the first message in the fresh session:

```text
DotNote 프로젝트를 /Users/toffler/DotNote 에서 이어서 진행해줘.
브랜치는 rebuild 이고, 먼저 docs/NEXT_SESSION_START.md, docs/DESIGN_HANDOFF_INDEX.md, docs/CLAUDE_CODE_CONTINUATION_BRIEF.md, docs/CURRENT_UI_BASELINE.md, docs/REDESIGN_WORKLOG.md, swift/HANDOFF_FOR_CLAUDE_CODE.md, REDESIGN_READINESS.md, REBUILD.md 를 읽어줘.
현재 SwiftUI 진입점은 DotNoteApp → DotNoteRootView → CalendarHomeView 이고, typed editors/settings/collections/Set A icon/launch screen까지 적용되어 있어.
최근에는 RealmSwift embed 런치 크래시 수정, drawing photo placement controls, drawing editor layout overflow fix, SwiftData legacy import validation, drawing color picker 개선, 펜 굵기 슬라이더 복원, 일기/그림 편집 모바일 레이아웃 점검까지 완료됐어.
다음은 현재 구조를 유지한 채 사용자가 지적하는 모바일 레이아웃/UI polish를 작은 단위로 진행해줘. 그림 사진 배치는 현재 in-canvas drag/scale 방식 유지, 실제 legacy default.realm은 없으므로 synthetic import 테스트를 회귀 안전망으로 봐줘.
저장/삭제 로직은 DotNoteAppModel 경로만 사용하고, migration/store 쪽은 검증 목적의 최소 변경만 해줘.
pbxproj 파일을 수정해야 하면 기존 24자리 ID와 충돌하지 않는지 반드시 grep으로 확인해줘.
작업 후 일반 UI 변경은 Orbit_Dev 테스트, 리소스/번들 변경은 Orbit_Dev 빌드와 Orbit_Prod 빌드를 확인하고 적절한 시점에 커밋해줘.
```
