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

Continue with UI polish, not another structural rewrite.

Recommended order:

1. Home screen visual refinement against the Set A brand tone.
2. Diary editor polish:
   - layout density
   - title/body hierarchy
   - weather/date treatment
   - light/dark parity
3. Memo overlay polish:
   - sizing
   - keyboard behavior
   - typography
   - save/cancel affordance clarity
4. Settings and collection polish:
   - card density
   - support rows
   - collection card image/text balance
5. Add or improve SwiftUI previews for light and dark modes using in-memory
   snapshots.
6. Later feature work:
   - legacy photo picker/crop/composite behavior
   - real legacy `.realm` migration verification
   - decide whether old UIKit screens stay in target or move to reference-only
     storage

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

- Standalone `simctl launch` may fail because RealmSwift dynamic framework
  resolution differs from the `xcodebuild test` environment. Prefer Xcode run or
  `xcodebuild test` for runtime checks.
- Existing drawing `imageData` is shown as a preview/background but cannot be
  reconstructed into editable PencilKit strokes.
- A real legacy `.realm` file is still needed before claiming migration is
  production-safe.
- Some older docs intentionally preserve historical milestone notes. For current
  state, trust this file plus `docs/CURRENT_UI_BASELINE.md` first.
