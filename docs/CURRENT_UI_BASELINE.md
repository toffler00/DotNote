# Current UI Baseline

This note captures the current app-entry and design-token baseline before the
next visible UI redesign pass.

## App Entry

- Current app entry is SwiftUI: `Orbit/Rebuild/App/DotNoteApp.swift`.
- `DotNoteApp` creates the SwiftData `ModelContainer`, creates
  `DotNoteAppModel`, loads app data in `.task`, and injects the model container.
- Current first screen route:
  - `DotNoteApp`
  - `DotNoteRootView`
  - `CalendarHomeView`
- The legacy UIKit `AppDelegate.swift` and UIKit screens remain in the repo for
  reference and compatibility work, but they are not the current rebuild entry.

## First Screen

`CalendarHomeView` is the first user-visible screen after launch.

It currently provides:

- `Dot Note` wordmark header.
- Settings entry point through `open-settings-button`.
- Expandable `새 기록` row with memo, drawing, and diary actions.
- Calendar-first month view.
- Selected-day entry list.
- Empty state when the selected day has no entries.

Persistence and mutations still flow through `DotNoteRootView` into
`DotNoteAppModel`; the home screen is view-layer only.

## Current Implemented UI Scope

The redesign is past the original Milestone 1 scaffold. Current implemented
surfaces include:

- Calendar-first home.
- Typed entry editors for diary, drawing, and memo.
- Settings surface.
- Font picker.
- Diary, memo, and drawing collection entry points.
- Settings support destinations for help and open-source license.
- Polished drawing editor canvas/tool surface.
- App icon and launch screen assets from the latest Set A pass.

See `docs/REDESIGN_WORKLOG.md` for milestone-by-milestone detail.

## Design Token Baseline

The app design-token source of truth is:

- `Orbit/Rebuild/App/DotNoteTheme.swift`

Reference-only design source:

- `swift/DotNoteTheme.swift`

The active token values are aligned with the latest Set A launch assets:

- Light paper / launch background: `#FFFEF6`
- Dark paper / launch background: `#1E1916`
- Light ink: `#3A302B`
- Dark ink: `#F2E9DE`
- Accent / dark app-icon dot: `#C9A56A`

All new visual work should use `DotNoteTheme` rather than local hardcoded color,
spacing, radius, shadow, or font constants.

## Next UI Work

The next recommended implementation unit is not another entry-point rewrite.
Start from the existing `CalendarHomeView` and continue polishing the visible
app surfaces in this order:

1. ~~Home screen visual refinement against the latest Set A brand tone.~~ Done —
   fixed the wordmark font (see `docs/REDESIGN_WORKLOG.md`); the rest of the
   home screen already read as clean and on-token.
2. ~~Entry editor polish, especially diary and memo density/typography.~~ Done —
   diary/drawing date+weather header restyled (Korean date capsule,
   weather-button affordance); diary/memo title-body grouping tightened with a
   hairline divider before the controls row. Drawing canvas also gained photo
   import (picked at explicit user request, pulled forward from unscheduled
   future work — see `docs/REDESIGN_WORKLOG.md`).
3. ~~Settings and collection polish.~~ Done — font list/help/license/collection
   sub-screens now share Settings root's custom header (flat chevron +
   wordmark title) instead of the system default nav bar's floating-pill back
   button. See `docs/REDESIGN_WORKLOG.md`.
4. ~~Preview coverage for light/dark states using in-memory snapshots.~~ Done —
   `DotNoteRootView`, `CalendarHomeView`, and `DotNoteSettingsView` now expose
   light/dark SwiftUI previews backed by shared in-memory preview data. Settings
   also includes an app-wide appearance mode picker (`system`, `light`, `dark`)
   persisted through SwiftData.

Partially addressed: legacy photo crop/reposition/scale parity for the drawing
canvas. Imported photos can now be repositioned by dragging and resized with a
pinch-style gesture before saving. This is not a separate legacy "Move and
Scale" crop screen, but it covers the practical in-canvas placement need.

Remaining follow-up checks:

- Manually verify the drawing photo-import flow with real Photos content on a
  simulator/device, including drag/scale placement before save.
- Run a real dark-mode visual pass on device/simulator if design tuning is
  needed beyond the current preview coverage.
- Real legacy `.realm` migration verification before release prep.

For capturing real (not guessed) screenshots of a mid-flow screen, see the
temporary-XCUITest-attachment method documented in `docs/REDESIGN_WORKLOG.md`
(the "Method" section under the date/weather-treatment milestone), plus the
`PackageFrameworks` launch recipe for standalone `simctl launch` runs.

For verification, use the lean operating rule:

- Normal UI/dev work: `Orbit_Dev` build + tests.
- Resource, bundle, app icon, or launch screen changes: `Orbit_Dev` build +
  `Orbit_Prod` build.
- `Orbit_Prod` tests only when Prod-specific logic changes.
