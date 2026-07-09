# Redesign Worklog

Running log of the Claude Code redesign passes against the SwiftUI rebuild.
Source of the design direction: `swift/HANDOFF_FOR_CLAUDE_CODE.md` (+ the
confirmed `swift/DotNoteTheme.swift`). Guardrails: `REDESIGN_READINESS.md`.

---

## Milestone 1 — Home screen + design tokens

Commit: `addbf55` — "Redesign home screen with design tokens (milestone 1)"
Branch: `rebuild`. Status: **done, build + UI test verified.**

### Scope

Applied the confirmed design pass to the calendar-first home. **View-layer only**
— no changes to Domain / Store / Migration / AppModel logic.

### Files

New:
- `Orbit/Rebuild/App/DotNoteTheme.swift` — single source of truth for design
  tokens: palette (warm light + warm dark), spacing, radii, card shadow,
  per-`DotNoteEntryKind` surfaces/dots/chips, `DotNoteFontTheme` (font-family
  wrapping so a brand font change never forces a data migration), `DotNoteType`
  (role-based fonts; wordmark fixed to Barunpen), `DotNoteWeather` (legacy label
  → SF Symbol). Copied verbatim from `swift/DotNoteTheme.swift`.
- `Orbit/Rebuild/App/DotNoteHomeView.swift` — `CalendarHomeView` + shared
  components: `MonthCalendar`, `CalendarDayCell`, `EntryRow`, `CreateActionRow`,
  `EmptyStateView`.

Modified:
- `Orbit/Rebuild/App/DotNoteRootView.swift` — root now hosts `CalendarHomeView`
  and routes create/edit via `.sheet`. `DotNoteEntryEditorMode.create` now
  carries a `DotNoteEntryKind` so the create pill can pre-select the type. The
  navigation bar is hidden (the home draws its own wordmark header).
- `Orbit/Info.plist` — registered `NanumBarunpenR.otf` in `UIAppFonts` (the
  wordmark face; the file was already bundled in Resources but not declared).
- `OrbitUITests/OrbitUITests.swift` — rewrote the smoke flow to the new create
  UX (tap `create-toggle` → tap `create-memo` → editor → save → the entry shows
  in the selected day's list → edit → delete → `empty-state`).
- `Orbit.xcodeproj/project.pbxproj` — registered the two new source files.

### Deliberate deviations from the handoff

- **File layout consolidated.** The handoff lists many files under
  `Design/Components` and `Screens/`. Because the Xcode project is **not** a
  synchronized folder group (see error #2 below), every new file needs manual
  pbxproj registration, so components + home were consolidated into one file to
  cut that risk. The guardrails (View-only, tokens in one place, font enum) are
  fully honored; only file names differ.
- **Interim editor kept.** The typed editors (Diary / Drawing / Memo overlay)
  are not built yet. The existing plain `Form` editor (`DotNoteEntryEditorView`,
  private in `DotNoteRootView.swift`, English titles "New Note"/"Edit Note") is
  reused so create/edit/delete and the smoke test stay green. It is replaced in
  milestone 2.
- `DotNoteMigrationPreviewView.swift` is now unused but still compiled; it will
  be removed or demoted to a debug section in a later milestone.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**, 0 errors.
- `OrbitUITests` smoke test: **passed** (~23s).
- Build/test command used (from `docs/NEXT_SESSION_START.md`):
  ```sh
  xcodebuild build -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev \
    -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
    ARCHS=arm64 ONLY_ACTIVE_ARCH=YES OTHER_CPLUSPLUSFLAGS=-Wno-invalid-specialization \
    CODE_SIGNING_ALLOWED=NO
  ```

---

## Errors encountered and root causes

### 1. Wordmark font never rendered (missing plist registration)

The design uses `NanumBarunpenR` for the "Dot Note" wordmark. `NanumBarunpenR.otf`
was already in the app bundle (Copy Bundle Resources) but was **not listed in
`Info.plist` → `UIAppFonts`**, so `.custom("NanumBarunpenR", …)` would silently
fall back to the system font. **Fix:** added `<string>NanumBarunpenR.otf</string>`
to `UIAppFonts`.

### 2. `xcodebuild` crash: "project is damaged" / `XCSwiftPackageProductDependency group unrecognized selector`

Adding the new files required hand-editing `project.pbxproj` (the project has no
`PBXFileSystemSynchronizedRootGroup`, so files are not auto-included). `plutil
-lint` reported the file as **valid**, yet `xcodebuild -list` and `build` failed
with:

```
-[XCSwiftPackageProductDependency group]: unrecognized selector sent to instance
xcodebuild: error: Unable to read project 'Orbit.xcodeproj'.
  Reason: The project 'Orbit' is damaged and cannot be opened.
```

**Root cause: object-ID collisions.** The project uses a hand-authored ID scheme
(`A100…0XXX`). The IDs first chosen collided with existing objects:
- `A10000000000000000000301` was already the **RealmSwift SPM product ref**
  (`XCSwiftPackageProductDependency`). Reusing it as a `PBXFileReference` made
  xcodebuild call `group` on the package-dependency object → crash.
- `A10000000000000000000114` was already **`LegacyRealmImportTests.swift`**.

`plutil` only validates plist syntax, not Xcode object-graph integrity, so it
passed. **Fix:** assigned collision-free IDs after grepping the full 24-char
literals — file refs `…0116` (Theme) / `…0115` (Home), build files `…0031` /
`…0032`. Lesson: before inventing a pbxproj ID, grep the **exact** full-length
string; watch specifically for SPM `productRef` IDs and test-target files.

### 3. Standalone `simctl launch` crashes (not a code bug — could not screenshot)

Launching `OrbitDEV.app` directly via `xcrun simctl launch` crashes at load:

```
Library not loaded: @rpath/RealmSwift.framework/RealmSwift  (terminated at launch)
```

The app links RealmSwift (SPM) as a dynamic framework that Xcode resolves via an
injected `DYLD_FRAMEWORK_PATH` during a test run, but a bare `simctl launch` has
no such path and `RealmSwift.framework` is not embedded in the `.app`. This is an
environment/launch limitation, **not** a defect in the redesign — the same build
runs fine under `xcodebuild test`. Consequence: no CLI runtime screenshot was
captured this pass.

Note (pre-existing, worth watching): if RealmSwift is not embedded ("Embed &
Sign"), a normal archive/run outside the test harness may hit the same missing
framework. Out of scope for the UI redesign; flag for the rebuild owner.

---

## Open caveats to confirm

- **Wordmark rendering unverified.** Could not capture a runtime screenshot (see
  error #3). Confirm in an Xcode Preview or a real simulator run that "Dot Note"
  renders in the Barunpen handwriting face. If it falls back to the system font,
  the PostScript name in `DotNoteFontTheme.postScriptName` (`"NanumBarunpenR"`)
  likely needs to match the font's actual PostScript name.

## Next milestones (handoff §4 order)

1. Typed editors: `DiaryEditorView`, `DrawingEditorView` (PencilKit canvas →
   `imageData`), `MemoOverlayView`; add `WeatherPicker`. Replace the interim
   `Form` editor and update `OrbitUITests` accordingly.
2. `SettingsView` + `FontListView` + `CollectionView`; wire the home `⋯` button
   (`open-settings-button`) to Settings.
3. Remove/repurpose `DotNoteMigrationPreviewView`. Add light/dark Previews per
   screen using `InMemoryDotNoteStore` snapshots.

---

## Milestone 2 — Typed editor shell + app icon

Commit: "Add typed entry editors and app icon"
Branch: `rebuild`. Status: **Dev/Prod build verified; UI test blocked by
environment approval/usage limit.**

### Scope

Continued the UI redesign from Milestone 1. This pass still keeps persistence
behind `DotNoteAppModel`; the editor views call only the existing create/update/
delete callbacks and do not touch Store / Migration / SwiftData code.

### Files

New:
- `Orbit/Rebuild/App/DotNoteEntryEditors.swift` — replaces the interim private
  `Form` editor with a typed editor router:
  - `DiaryEditorView`
  - `DrawingEditorView`
  - `MemoOverlayView`
  - shared `WeatherPicker`
  - PencilKit-backed drawing canvas wrapper
  - shared draft, delete button, alignment toolbar, drawing toolbar helpers
- `appicon/` — source/master app icon handoff assets and generated
  `AppIcon.appiconset`.

Modified:
- `Orbit/Rebuild/App/DotNoteRootView.swift` — now passes `settings` into
  `DotNoteEntryEditorView` and no longer contains the interim private `Form`
  editor.
- `OrbitUITests/OrbitUITests.swift` — smoke flow now expects the memo overlay
  instead of the old `"New Note"` / `"Edit Note"` navigation bars.
- `Orbit.xcodeproj/project.pbxproj` — registered `DotNoteEntryEditors.swift`
  with collision-checked IDs:
  - file ref `A10000000000000000000117`
  - build file `A10000000000000000000033`
- `Orbit/Assets.xcassets/AppIcon.appiconset/` and
  `Orbit/Assets.xcassets/AppIcon_dev.appiconset/` — replaced with the new Dot
  Note icon set from `appicon/AppIcon.appiconset`.

### Verification

- `plutil -lint Orbit.xcodeproj/project.pbxproj`: **OK**.
- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Prod` simulator build: **BUILD SUCCEEDED**.
- `Orbit_Dev` UI test: **not completed**. The first sandboxed run failed before
  tests started because CoreSimulatorService became unavailable and Swift
  package sandboxing failed. Retrying with escalated simulator access was blocked
  by the current Codex usage/approval limit, so no UI-test result is available
  for this pass.

### Caveats / next checks

- Run `Orbit_Dev` UI tests once simulator access is available again.
- Drawing editor currently saves new PencilKit strokes to `imageData`; loading
  existing `imageData` back into an editable PencilKit canvas is not implemented
  yet.
- Settings, font picker, collection views, and the home `⋯` settings route are
  still the next UI milestone.

---

## Milestone 3 — Settings, font picker, and collection entry points

Commit: "Add settings and font picker redesign"
Branch: `rebuild`. Status: **Dev build + unit/UI tests verified.**

### Scope

Added the first settings milestone from the redesign handoff. The home `⋯`
button now opens a SwiftUI settings surface using the established Dot Note
tokens. Font selection is functional and persists through the existing
`DotNoteAppModel` boundary; collection entry points render diary/memo views from
the current entries. This pass keeps entry CRUD and SwiftData migration behavior
intact.

### Files

Modified:
- `Orbit/Rebuild/App/DotNoteRootView.swift` — routes the home settings button to
  a root-level `DotNoteSettingsView` overlay.
- `Orbit/Rebuild/App/DotNoteEntryEditors.swift` — adds `DotNoteSettingsView`,
  `DotNoteFontListView`, `DotNoteCollectionView`, collection cards, and shared
  settings rows/groups using `DotNoteTheme`.
- `Orbit/Rebuild/App/DotNoteAppModel.swift` — adds settings update and all-data
  delete commands so Views still route persistence through AppModel.
- `Orbit/Rebuild/Store/*` — extends the store boundary with `updateSettings` and
  `deleteAllData`, implemented for SwiftData and in-memory test storage.
- `OrbitTests/OrbitTests.swift` — covers SwiftData settings update, all-data
  deletion, and AppModel settings updates.
- `OrbitUITests/OrbitUITests.swift` — adds a smoke flow for opening settings,
  selecting a body font, and returning home.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test run: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped external Realm fixture, 0 failures.
  - UI tests: 2 executed, 0 failures.

### Caveats / next checks

- Support rows (`의견보내기`, `사용법`, `Open-source License`) are visual entry
  points only; their destination content is still a later milestone.
- Collection views are read-only entry points for diary/memo. Editing from
  collection cards and drawing collection coverage remain future work.

---

## Milestone 4 — Collection cards open existing editors

Commit: "Open entries from settings collections"
Branch: `rebuild`. Status: **Dev build + full test suite verified.**

### Scope

Made the settings collection entry points functional. Diary/memo collection cards
now route back through the existing root coordinator and open the same
type-specific editor used by the calendar home, keeping persistence behind
`DotNoteAppModel`.

### Files

Modified:
- `Orbit/Rebuild/App/DotNoteRootView.swift` — passes `onSelectEntry` into
  `DotNoteSettingsView`; selecting an entry dismisses settings and opens the
  editor in `.edit` mode.
- `Orbit/Rebuild/App/DotNoteEntryEditors.swift` — makes diary/memo collection
  cards tappable, exposes stable accessibility identifiers for collection cards,
  and collapses each card into a single accessibility element.
- `OrbitUITests/OrbitUITests.swift` — adds a smoke flow for creating a memo,
  opening Settings → Memo collection, tapping the collection card, and verifying
  the memo editor opens with the existing title.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test run: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped external Realm fixture, 0 failures.
  - UI tests: 3 executed, 0 failures.

### Caveats / next checks

- Collection cards now open editors for diary/memo; drawing collection entry
  coverage is still pending.
- Support rows (`의견보내기`, `사용법`, `Open-source License`) remain visual-only
  until their destinations are designed.

---

## Milestone 5 — Settings support destinations

Commit: "Connect settings support destinations"
Branch: `rebuild`. Status: **Dev/Prod build + full test suite verified.**

### Scope

Connected the Settings support rows to functional SwiftUI destinations/actions.
The feedback row now preserves the legacy recipient, subject, and message body
through a `mailto:` URL. The help row opens a compact SwiftUI usage guide, and
the license row opens the bundled `opensourceLicense.md` content inside a
SwiftUI reader.

### Files

Modified:
- `Orbit/Rebuild/App/DotNoteEntryEditors.swift` — connects feedback/help/license
  rows, adds `DotNoteHelpView`, adds `DotNoteLicenseView`, and loads the bundled
  open-source license markdown.
- `OrbitUITests/OrbitUITests.swift` — adds a settings support smoke flow for the
  help and license destinations.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test run: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped external Realm fixture, 0 failures.
  - UI tests: 4 executed, 0 failures.
- `Orbit_Prod` simulator build: **BUILD SUCCEEDED**.

### Caveats / next checks

- Feedback uses `mailto:` and is not automated in UI tests because it depends on
  Mail/default handler availability in the simulator environment.
- Drawing collection coverage remains pending.

---

## Milestone 6 — Restore Xcode 26.5 builds

Commit: "Update Realm for Xcode 26.5 builds"
Branch: `rebuild`. Status: **Dev/Prod build + full test suite verified.**

### Scope

Fixed the Xcode UI build failure caused by Realm Core's older S2 C++ sources
being compiled by Xcode 26.5. The previous `realm-swift` pin (`10.54.6`) failed
with `is_pod cannot be specialized` in `s2geometry`. Updated Realm to the
current Xcode 26.5-compatible line while preserving the existing legacy Realm
import path.

### Files

Modified:
- `Orbit.xcodeproj/project.pbxproj` — raises the `realm-swift` package minimum
  version to `20.0.5`.
- `Orbit.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` —
  pins `realm-swift` to `20.0.5` and `realm-core` to `20.1.5`.
- `Orbit.xcworkspace/xcshareddata/swiftpm/Package.resolved` — mirrors the same
  resolved package pins for workspace users.

### Verification

- `Orbit_Dev` simulator build without the prior CLI C++ workaround:
  **BUILD SUCCEEDED**.
- `Orbit_Prod` simulator build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test run: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped external Realm fixture, 0 failures.
  - UI tests: 4 executed, 0 failures.

### Caveats / next checks

- The old UIKit/Realm code remains in the target for now, mainly to keep the
  legacy import path available while the SwiftUI rebuild matures.
- A later cleanup pass should decide whether legacy UIKit screens stay as
  reference-only files or move out of the app build target.

---

## Milestone 7 — Drawing collection routing

Commit: "Open drawings from settings collection"
Branch: `rebuild`. Status: **Dev/Prod build + full test suite verified.**

### Scope

Completed the missing Settings collection route for drawing entries. Settings
now exposes a `그림보기` row alongside diary and memo collections. Drawing cards
use the existing collection card layout and route through the root coordinator
into the current drawing editor in edit mode.

### Files

Modified:
- `Orbit/Rebuild/App/DotNoteEntryEditors.swift` — adds the Settings drawing
  collection row and extends the collection filter to `.drawing`.
- `OrbitUITests/OrbitUITests.swift` — adds a UI smoke flow for creating a
  drawing entry, opening Settings → Drawing collection, tapping the card, and
  verifying the drawing editor reopens with the saved title.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test run: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped external Realm fixture, 0 failures.
  - UI tests: 5 executed, 0 failures.
- `Orbit_Prod` simulator build: **BUILD SUCCEEDED**.

### Caveats / next checks

- The drawing collection route is now covered, but the actual drawing editor
  still uses the current functional SwiftUI/PencilKit design rather than the
  final redesign polish.

---

## Milestone 8 — Drawing editor UI polish

Commit: "Polish drawing editor canvas tools"
Branch: `rebuild`. Status: **Dev/Prod build + full test suite verified.**

### Scope

Polished the SwiftUI/PencilKit drawing editor surface before adding larger
legacy features such as photo import/crop. The editor now presents a taller
white canvas board, displays existing saved `imageData` as a non-destructive
background preview, and exposes a more modern tool palette with selected color
rings, icon buttons, a line-width slider, and stronger accessibility metadata.

### Files

Modified:
- `Orbit/Rebuild/App/DotNoteEntryEditors.swift` — introduces the drawing canvas
  board, shared drawing palette, icon button styling, saved-image preview, and
  explicit accessibility labels for drawing controls.
- `OrbitUITests/OrbitUITests.swift` — extends the drawing collection smoke test
  to verify that the reopened drawing editor exposes the canvas, toolbar, color
  swatch, pen/eraser toggle, and undo controls.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test run: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped external Realm fixture, 0 failures.
  - UI tests: 5 executed, 0 failures.
- `Orbit_Prod` simulator build: **BUILD SUCCEEDED**.

### Caveats / next checks

- Existing `imageData` is shown as a preview/background, but it still cannot be
  reconstructed into editable PencilKit strokes. New strokes save as the current
  canvas output, and entries with no new strokes preserve the previous image.
- Legacy photo picker/crop/composite behavior is still a separate feature pass.
