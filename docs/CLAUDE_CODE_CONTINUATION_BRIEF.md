# Claude Code Continuation Brief

This is the short operational handoff for Claude Code. Read it before starting
the next implementation pass, then use the linked docs for deeper detail.

## Current Repository State

- Repo: `/Users/toffler/DotNote`
- Branch: `rebuild`
- Remote branch: `origin/rebuild`
- Production bundle ID to preserve: `io.orbit.orbit.prod`
- Current app direction: revive the old UIKit/Realm Dot Note app as a modern
  SwiftUI + SwiftData app while preserving legacy data through a read-only Realm
  import bridge.
- Current working-tree note: `Set-A/` and `launch/` are user-provided source
  asset folders and intentionally remain untracked unless the user asks to
  archive them in git.

## Read Order

1. `docs/CURRENT_UI_BASELINE.md`
2. `docs/REDESIGN_WORKLOG.md`
3. `docs/NEXT_SESSION_START.md`
4. `docs/DESIGN_HANDOFF_INDEX.md`
5. `swift/HANDOFF_FOR_CLAUDE_CODE.md`
6. `REDESIGN_READINESS.md`
7. `REBUILD.md`

## What Has Been Done

### Rebuild Direction

- The active app path is SwiftUI:
  - `Orbit/Rebuild/App/DotNoteApp.swift`
  - `DotNoteRootView`
  - `CalendarHomeView`
- Long-term persistence direction is SwiftData.
- Legacy Realm remains available as an import source, not the future primary
  database.
- Existing App Store continuity must be preserved through the production bundle
  ID `io.orbit.orbit.prod`.

### Core App Structure

- `DotNoteAppModel` is the app-level boundary for loading, creating, updating,
  deleting, settings updates, and all-data deletion.
- `Store/*` contains SwiftData and in-memory store implementations.
- `Migration/*` contains the legacy Realm import path.
- `Domain/DotNoteModels.swift` defines semantic app models.
- SwiftUI Views should not write directly to SwiftData or Realm.

### UI Completed So Far

- Calendar-first home screen.
- Expandable `새 기록` create row.
- Typed editors:
  - diary
  - drawing
  - memo overlay
- Weather picker.
- Settings surface.
- Font picker.
- Diary, memo, and drawing collection entry points.
- Collection cards route back to the existing editors.
- Help and open-source license destinations.
- Drawing editor polish:
  - larger canvas board
  - saved image preview/background
  - color swatches
  - pen/eraser controls
  - line-width slider
  - undo control
- Latest app icon and launch screen assets from `Set-A`.
- Launch screen central logo is fixed at `210pt x 210pt`.
- Wordmark and font picker now use verified custom-font PostScript names for
  all seven bundled font choices.
- Diary/drawing editors use a Korean date capsule plus native graphical picker
  sheet, replacing the raw system `DatePicker` resting control.
- Weather picker unselected buttons now have a visible hairline affordance.
- Diary/memo title-body hierarchy has been tightened with clearer grouping and
  controls-row separation.
- Drawing editor now supports photo import as a canvas background through
  `PhotosPicker`, with photo+PencilKit strokes composited into `imageData` on
  save.
- Drawing editor photo placement now supports in-canvas adjustment:
  - photo adjustment mode,
  - drag repositioning,
  - pinch-style scale from `0.5x` to `4x`,
  - reset placement,
  - save compositing that respects the adjusted rect.
- Drawing editor toolbar/weather rows are constrained to the device width; long
  control rows scroll internally instead of widening the whole editor layout.
- Diary and drawing editor weather rows now expand to the available device
  width while keeping their weather buttons inside an internal horizontal
  scroll row.
- Diary and drawing editor top-right save/check buttons are constrained to a
  fixed circular `36pt x 36pt` hit shape so the circle is not clipped vertically.
- Drawing editor color selection was redesigned as a compact custom popover
  with preset swatches plus hue/saturation/brightness sliders.
- Drawing editor pen-width control remains the existing slider interaction by
  product decision, but its toolbar footprint was narrowed so photo, pen/eraser,
  undo, and related controls fit into one horizontally scrolling row on mobile.
- Drawing editor photo import is now guarded so pen input does not accidentally
  clear the selected/background photo state.
- Settings sub-screens now share the custom Settings header instead of falling
  back to the system navigation bar.
- Settings now includes app-wide appearance selection (`system`, `light`,
  `dark`), persisted through SwiftData and applied through
  `preferredColorScheme`.
- Light/dark preview coverage exists for root, home, and settings views.
- Legacy Realm -> SwiftData import flow has unit coverage for initial import,
  duplicate-import prevention, and preserving an already-initialized SwiftData
  store.

### Design Tokens

- Active token file: `Orbit/Rebuild/App/DotNoteTheme.swift`
- Reference design token file: `swift/DotNoteTheme.swift`
- The current Set A brand baseline:
  - light paper / launch background: `#FFFEF6`
  - dark paper / launch background: `#1E1916`
  - light ink: `#3A302B`
  - dark ink: `#F2E9DE`
  - accent / dark icon dot: `#C9A56A`
- New UI work should use `DotNoteTheme` for color, spacing, radius, shadow, and
  font decisions. Do not scatter new visual constants through View files.

### Latest Relevant Commits

- `c6e0075` — Expand editor weather picker layout
- `c6edccf` — Refine drawing editor toolbar layout
- `e6ae787` — Constrain editor save buttons
- `7c585c9` — Restore drawing width slider
- `f722422` — Add custom drawing color picker
- `7b7018f` — Polish drawing toolbar selection controls
- `0e42bd4` — Guard drawing photo clear during pen input
- `b91b0aa` — Document photo e2e verification, dark-mode pass, and legacy reorg
- `9c02495` — Relocate legacy UIKit source into Orbit/Legacy/
- `a7267f3` — Update Claude handoff with migration status
- `b91e681` — Validate SwiftData legacy import flow
- `a00a3f2` — Constrain drawing editor toolbar layout
- `0836434` — Embed RealmSwift framework in app bundle
- `74cdd0e` — Add drawing photo placement controls
- `2009a9c` — Add appearance mode setting and previews
- `5feed48` — Update continuation brief with Claude Code work
- `e766dac` — Document settings header consistency fix; sync baseline status
- `b004a70` — Unify settings sub-screen headers; remove destructive-title string check
- `5c5d1be` — Document editor hierarchy polish and drawing photo import
- `bb8577b` — Polish editor content hierarchy; add photo import to drawing canvas
- `4059194` — Sync Next UI Work status with completed milestones
- `09fe83c` — Document editor date/weather polish and screenshot-capture method
- `674bf36` — Polish diary/drawing editor date and weather treatment
- `c007cb7` — Document wordmark font fix and runtime screenshot recipe
- `7f6e05e` — Fix mismatched PostScript names for 4 custom fonts
- `0e1569e` — Document current UI baseline and tokens
- `efbcfae` — Replace app icon and launch screen assets
- `a08005d` — Increase launch screen logo size
- `19b6c2d` — Apply redesigned launch screen
- `54bf7a5` — Polish drawing editor canvas tools
- `8d155a2` — Open drawings from settings collection
- `b48481d` — Update Realm for Xcode 26.5 builds
- `138f922` — Connect settings support destinations
- `65ee425` — Open entries from settings collections
- `beff519` — Add settings and font picker redesign
- `45d3571` — Add typed entry editors and app icon

## Important Guardrails

- Preserve `io.orbit.orbit.prod`.
- Keep persistence, migration, filtering, and networking out of SwiftUI View
  bodies.
- Route mutations through `DotNoteAppModel`.
- Treat old UIKit files as reference unless a task explicitly asks for legacy
  cleanup.
- Do not remove the Realm import bridge until real legacy `.realm` migration has
  been verified.
- If adding Swift files to the Xcode project manually, grep exact 24-character
  pbxproj IDs before inventing new ones. This repo previously hit object-ID
  collisions that made Xcode report the project as damaged.
- Do not commit `Set-A/` or `launch/` unless explicitly requested; their applied
  assets already live in `Orbit/Assets.xcassets` and
  `Orbit/Base.lproj/LaunchScreen.storyboard`.

## Recommended Next Work

Continue with small mobile UI polish and release-readiness checks. Avoid another
structural rewrite unless the user explicitly asks for it.

Recommended order:

1. ~~Manually verify the drawing photo-import flow~~ Done — verified end-to-end
   via simulator (seeded photo library + XCUITest driving the real PHPicker
   sheet). Pick → canvas → save → reopen persistence confirmed, reproduced 5+
   times. One open, unreproduced observation from a two-consecutive-strokes
   pattern (possible photo loss) needs a real-device/finger check — see
   `docs/REDESIGN_WORKLOG.md` for the exact repro attempt and why it's not
   confirmed as a real bug yet.
2. ~~Real legacy `.realm` migration verification~~ Product decision updated —
   the user no longer has an old Realm backup. Treat migration readiness as
   current-app regression safety: synthetic Realm import coverage and the
   SwiftData import-flow tests should keep passing, and the app should not
   malfunction when no external legacy file exists.
3. ~~Run a real light/dark visual pass~~ Done — simulator system-appearance
   toggle + real screenshots of home/diary editor/memo overlay/Settings. Clean,
   no contrast issues, warm dark palette holds up everywhere. See
   `docs/REDESIGN_WORKLOG.md`.
4. Later feature work:
   - ~~decide whether the in-canvas drawing photo placement is enough~~ Decided
     — keep the current in-canvas drag/scale placement. Do not recreate the
     legacy-style separate "Move and Scale" crop screen unless the product
     direction changes later.
   - ~~continue drawing editor UI polish around color selection~~ Done — custom
     color popover with preset swatches and HSB sliders is applied.
   - ~~decide pen-width UX~~ Decided — keep the existing slider interaction, but
     keep its mobile footprint compact.
   - ~~decide whether old UIKit screens stay in target or move to
     reference-only storage~~ Decided — moved to `Orbit/Legacy/` now (commit
     `9c02495`), rather than waiting for migration verification. See
     `docs/REDESIGN_WORKLOG.md` for what moved and the one active-resource
     exception (`opensourceLicense.md`).

Next practical tasks:

1. Do a focused real-device visual pass for diary and drawing editors after any
   future editor layout change:
   - top save/check button remains a complete circle,
   - weather picker fills the visible width without making the editor wider
     than the screen,
   - drawing toolbar stays usable on small phones,
   - photo import adjustment mode does not resize the whole editor outside the
     safe area.
2. If the user wants more editor polish, stay in `DotNoteEntryEditors.swift`
   first. Current likely polish areas are spacing, toolbar grouping, and color
   picker affordance; do not change Store/Migration for this class of work.
3. Before release-oriented work, run `Orbit_Prod` build once in addition to the
   normal `Orbit_Dev` build/test.

Recently completed:

- Expanded diary/drawing weather pickers to the mobile screen width.
- Narrowed the drawing pen-width slider area so drawing toolbar controls fit in
  one horizontally scrolling row.
- Fixed diary/drawing save button clipping by reducing and constraining the
  circular check button.
- Restored the user's preferred pen-width slider UX after briefly exploring a
  compact preset-style control.
- Added the redesigned drawing color picker popover.
- Ran a lightweight mobile layout check for the diary/drawing editor paths:
  `Orbit_Dev` build succeeded, and `Orbit_Dev` full tests succeeded
  (19 tests total, 1 skipped legacy external fixture, 0 failures). No code
  changes were made during that check.
- Added SwiftData legacy import validation: first-load import, duplicate import
  prevention, settings/image/text/date preservation, and skip behavior when
  SwiftData already has records.
- Fixed a launch-time dyld crash by embedding `RealmSwift.framework` in the app
  target's `Embed Frameworks` phase.
- Fixed drawing editor photo-adjustment layout overflow by constraining long
  weather/toolbar rows to scroll internally.
- Added in-canvas drawing photo placement controls: adjustment mode, drag
  reposition, pinch-style scale, reset, and save compositing that respects the
  adjusted rect. Clearing a photo now persists as cleared instead of restoring
  previous `imageData`.
- Added app-wide appearance mode selection in Settings (`system`, `light`,
  `dark`), persisted via SwiftData and applied through `preferredColorScheme`.
- Added light/dark SwiftUI previews for root, home, and settings using shared
  in-memory preview data.

## Verification Policy

Use the lean test policy already agreed in this thread.

- Normal UI/dev work:
  - `Orbit_Dev` build
  - `Orbit_Dev` full tests when behavior or accessibility identifiers change
- Resource, app icon, launch screen, bundle, or scheme-sensitive changes:
  - `Orbit_Dev` build
  - `Orbit_Prod` build
- `Orbit_Prod` tests only when Prod-specific logic changes.

Current commands:

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Prod -configuration Prod -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

## Known Caveats

- Standalone `simctl launch` is now usable after embedding
  `RealmSwift.framework` in the app bundle. The screenshot-capture recipe is
  documented in `docs/REDESIGN_WORKLOG.md`.
- Existing drawing `imageData` is shown as a preview/background but cannot be
  reconstructed into editable PencilKit strokes.
- Imported drawing photos can be repositioned/scaled before save, but this is
  not a separate legacy-style crop screen.
- End-to-end PhotosPicker automation is still limited because the system Photos
  UI is outside the app's normal accessibility surface in this environment.
- Synthetic Realm import and SwiftData migration unit tests pass, but a real
  legacy user `.realm` file is still needed before claiming migration is
  production-safe.
- Some older docs intentionally preserve historical milestone notes. For current
  state, trust this file plus `docs/CURRENT_UI_BASELINE.md` first.
