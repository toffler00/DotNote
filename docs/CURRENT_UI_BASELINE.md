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

1. Home screen visual refinement against the latest Set A brand tone.
2. Entry editor polish, especially diary and memo density/typography.
3. Settings and collection polish.
4. Preview coverage for light/dark states using in-memory snapshots.

For verification, use the lean operating rule:

- Normal UI/dev work: `Orbit_Dev` build + tests.
- Resource, bundle, app icon, or launch screen changes: `Orbit_Dev` build +
  `Orbit_Prod` build.
- `Orbit_Prod` tests only when Prod-specific logic changes.
