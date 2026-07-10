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

---

## Milestone 9 — Launch screen assets

Commit: "Apply redesigned launch screen"
Branch: `rebuild`. Status: **Dev/Prod build verified.**

### Scope

Applied the redesigned Dot Note launch screen resources. The launch storyboard
now uses a centered `LaunchLogo` image on a named `LaunchBackground` color, with
light/dark asset variants supplied through the asset catalog.

### Files

Modified:
- `Orbit/Base.lproj/LaunchScreen.storyboard` — replaces the old full-screen
  `DotnoteLaunch` image layout with a centered logo and named background color.

Added:
- `Orbit/Assets.xcassets/LaunchLogo.imageset/` — light/dark launch logo PNGs at
  1x, 2x, and 3x.
- `Orbit/Assets.xcassets/LaunchBackground.colorset/` — light/dark launch
  background named color.

### Verification

- `Orbit_Dev` simulator build: **BUILD SUCCEEDED**.
- `Orbit_Prod` simulator build: **BUILD SUCCEEDED**.

### Caveats / next checks

- Full UI tests were intentionally skipped for this resource-only change.
- The source `launch/` folder remains as the user-provided working input and is
  not required by the app target.

---

## Milestone — Wordmark font bug fix + runtime screenshot verification unblocked

Commit: `7f6e05e` — "Fix mismatched PostScript names for 4 custom fonts"
Branch: `rebuild`. Status: **done, build + full test suite verified, fix
confirmed visually via simulator screenshot.**

### Context

`docs/REDESIGN_WORKLOG.md` (Milestone 1) had flagged as an open, unverified
caveat: *"Confirm in an Xcode Preview or a real simulator run that 'Dot Note'
renders in the Barunpen handwriting face."* This pass resolved both that caveat
and the underlying blocker that had prevented checking it (standalone `simctl
launch` crashing).

### Finding #1 (blocker resolved): the correct dyld framework path for standalone `simctl launch`

Milestone 1 recorded `simctl launch` as unusable for runtime screenshots because
of a missing `RealmSwift.framework` dyld error, and pointed
`DYLD_FRAMEWORK_PATH` at the build **Products** directory — which does not
actually contain `RealmSwift.framework` (only `.o`/`.swiftmodule` remnants).

The framework actually lives one level down, in the SPM package-products
subfolder:

```
<DerivedData>/Build/Products/Dev-iphonesimulator/PackageFrameworks/RealmSwift.framework
```

Pointing `DYLD_FRAMEWORK_PATH` at that `PackageFrameworks` folder (not the
Products root) lets a bare `simctl launch` succeed:

```sh
PRODUCTS=~/Library/Developer/Xcode/DerivedData/Orbit-*/Build/Products/Dev-iphonesimulator
FW="$PRODUCTS/PackageFrameworks"
SIMCTL_CHILD_DYLD_FRAMEWORK_PATH="$FW" SIMCTL_CHILD_DYLD_FALLBACK_FRAMEWORK_PATH="$FW" \
  xcrun simctl launch <device-id> io.orbit.orbit.prod --dotnote-ui-testing
```

This unblocks real runtime screenshot verification going forward — earlier
milestones had to rely solely on `xcodebuild test` passing, with no visual
check. `docs/CLAUDE_CODE_CONTINUATION_BRIEF.md`'s "Known Caveats" entry about
preferring Xcode run / `xcodebuild test` is still reasonable general advice,
but this path is a viable fallback when a screenshot is specifically needed.

### Finding #2 (real bug, fixed): 4 of 7 custom fonts had wrong `postScriptName`

With runtime screenshots working, the home screen "Dot Note" wordmark was
visibly rendering in the system sans-serif font, not the intended Barunpen
handwriting face — confirming the Milestone 1 caveat was a real bug, not just
an unverified assumption.

Root cause: `DotNoteFontTheme.postScriptName` values were derived from font
**filenames**, not the fonts' actual registered PostScript names (`name` table,
nameID 6). Verified every case against the real `.otf`/`.ttf` via `fontTools`:

| case | coded (wrong) | actual PostScript name |
| --- | --- | --- |
| `barunpen` | `NanumBarunpenR` | `NanumBarunpen` |
| `shinb7` | `SSShinb7` | `SangSangShinb7` |
| `flowerRoad` | `SSFlowerRoad` | `SangSangFlowerRoad` |
| `rock` | `SSRock` | `SangSangRock` |

(`barunGothic`, `myeongjo`, `brush` were already correct.) `barunpen` is fixed
as `DotNoteType.wordmark`, so this silently broke the wordmark on **every
screen**; `shinb7`/`flowerRoad`/`rock` are 3 of the 7 selectable body-font
themes in the font picker, so choosing any of them would silently render body
text in the system font instead.

**Fix:** corrected the 4 strings in `Orbit/Rebuild/App/DotNoteTheme.swift`
(`DotNoteFontTheme.postScriptName`) — the single source of truth, so no other
file needed changes. Confirmed no other file hardcodes these font-name strings
(`grep` came back empty).

**Method note for future font additions:** don't infer PostScript name from the
filename. Extract it directly:
```sh
python3 -c "
from fontTools.ttLib import TTFont
f = TTFont('path/to/font.otf')
for r in f['name'].names:
    if r.nameID == 6: print(r.toUnicode())
"
```
(`fontTools` was not preinstalled; installed into a throwaway venv —
`python3 -m venv /tmp/fontenv && /tmp/fontenv/bin/pip install fonttools`.)

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test suite (`OrbitTests` + `OrbitUITests`, 15 tests total):
  **all passed**, no regressions.
- Visual: simulator screenshot before/after confirms the wordmark switched from
  system sans-serif to the Barunpen pen face.

### Not done in this pass

Beyond the font fix, the home screen render was inspected but no other visual
change was made — the calendar card, empty state, and create-row already read
as clean and on-token against `DotNoteTheme`. Further "visual refinement"
(item 1 in `docs/CURRENT_UI_BASELINE.md` → Next UI Work) can now be iterated on
*with real screenshots* going forward, using the `PackageFrameworks` launch
recipe above instead of guessing from code alone.

Next up per the agreed order: diary/memo editor density and typography polish
(`docs/CURRENT_UI_BASELINE.md` → Next UI Work, item 2).

---

## Milestone — Diary/drawing editor date & weather treatment

Commit: `674bf36` — "Polish diary/drawing editor date and weather treatment"
Branch: `rebuild`. Status: **done, build + full test suite verified, fix
confirmed visually via simulator screenshots (before/after).**

### Method: capturing real screenshots of interactive states via a temporary XCUITest

Static launch screenshots (previous milestone) only reach the home screen.
To see an editor mid-interaction (a real target for "polish"), added a
throwaway UI test method that walks the flow and attaches screenshots as
`XCTAttachment(lifetime: .keepAlways)`, ran it with a `-resultBundlePath`, then
extracted the PNGs:

```sh
xcodebuild test -project Orbit.xcodeproj -scheme Orbit_Dev -configuration Dev \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -only-testing:OrbitUITests/OrbitUITests/testZZZCaptureEditorScreenshots \
  -resultBundlePath /path/to/result.xcresult ARCHS=arm64 ONLY_ACTIVE_ARCH=YES \
  CODE_SIGNING_ALLOWED=NO

xcrun xcresulttool export attachments --path /path/to/result.xcresult --output-path /path/to/out
```

The test method opened the diary/memo/drawing editors via the existing
`create-toggle` → `create-<kind>` flow, typed sample Korean text into the title/
body fields, and attached a screenshot at each stop. It was added, run twice
(before/after the fix), then **deleted** — it is not part of the permanent
suite. This is a reusable recipe for future polish passes: prefer it over
guessing from source alone whenever a change targets a mid-flow screen the
static home screenshot can't reach.

### What the screenshots showed

With real screenshots of the diary and drawing editors (which share
`EditorDateWeatherHeader`), two concrete issues were visible that source
reading alone hadn't surfaced:

1. **Date control was the raw system `DatePicker` compact style** — rendered as
   a plain gray pill in English (`"Jul 9, 2026"`), in the system font, ignoring
   `DotNoteTheme` typography/color entirely and breaking from the Korean
   date+weekday convention used everywhere else in the redesign (e.g. the home
   screen's `"7월 9일 · 목요일"` selected-day header).
2. **`WeatherPicker`'s unselected buttons had almost no visible affordance** —
   their resting fill (`Palette.paper`) was nearly identical to the header
   card's background (`Palette.card`, off-white vs. white), so unselected
   weather icons looked like static glyphs rather than tappable controls.

Both are explicitly in scope: `docs/CURRENT_UI_BASELINE.md` → Next UI Work
item 2 names "weather/date treatment" directly.

### Fix

In `Orbit/Rebuild/App/DotNoteEntryEditors.swift`, `EditorDateWeatherHeader`:

- Replaced the inline `DatePicker` with a themed capsule button
  (`kind.chipBackground`/`chipForeground`, app typography) showing
  `"M월 d일 EEEE"` in `ko_KR`. Tapping it presents a `.sheet` with a
  `.graphical` `DatePicker` (`.presentationDetents([.medium])`) for actual date
  entry — full control over the resting-state look, native picker for input.
  Kept the `entry-date-picker` accessibility identifier on the new button (not
  referenced by any existing test, so no test changes were needed here).
- Added a `hairline` stroke to `WeatherPicker`'s unselected state so the six
  weather buttons read as a button group at rest, not floating icons. Selected
  state (amber fill, per `Palette.today`) is unchanged.

Shared component, so the fix applies to both `DiaryEditorView` and
`DrawingEditorView` from one change. `MemoOverlayView` doesn't use this header
(no date/weather fields by design) and was left untouched — it already read as
clean and on-token in the screenshot pass.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test suite (`OrbitTests` + `OrbitUITests`): **all 15 passed**,
  no regressions.
- Visual: before/after screenshots via the method above confirm the date pill
  now reads `"7월 9일 목요일"` in the diary-tint capsule (diary editor) / drawing
  tint (drawing editor), and the weather buttons show a visible hairline
  boundary at rest.

### Not done in this pass

- Diary/memo *density and typography hierarchy* beyond the date/weather header
  — title/body spacing already read reasonably clean in the screenshots and
  was left alone to keep this change scoped to the concrete issue found.
- Dark-mode screenshots were not captured (`XCUIApplication` launch-time
  color-scheme override wasn't wired up for this pass); the token values for
  dark were reasoned about from `DotNoteTheme` but not visually confirmed.
  Light/dark parity is item 4 in `docs/CURRENT_UI_BASELINE.md` → Next UI Work.

Next up per the agreed order: settings and collection polish (`docs/CURRENT_UI_BASELINE.md`
→ Next UI Work, item 3), then light/dark preview coverage (item 4).

---

## Milestone — Editor content hierarchy + drawing photo import

Commit: `bb8577b` — "Polish editor content hierarchy; add photo import to
drawing canvas"
Branch: `rebuild`. Status: **done, build + full test suite verified, both
changes confirmed visually via simulator screenshots.**

### Part 1: diary/memo title-body hierarchy

Completes the remaining part of item 2 (density/typography) left open by the
previous milestone. In `DiaryEditorView` and `MemoOverlayView`, title and body
sat in one `VStack` with a single uniform spacing value shared with the
"controls" row below (alignment toolbar for diary; delete/save row for memo),
so nothing visually distinguished "this is one written thing" from "these are
actions on it."

Fix: tightened the title→body gap (`Spacing.md` → `Spacing.sm`) so they read as
one grouped block, and added a 1pt `hairline`-colored `Rectangle()` divider
directly before the controls row. Same pattern applied to both editors for
consistency. Confirmed via screenshots (`diary-editor-hierarchy`,
`memo-overlay-hierarchy`) that the divider renders correctly above the (below-
the-fold, keyboard-covered) controls row in both.

### Part 2: drawing canvas photo import (new feature, not prior scope)

The user asked to add photo import to the drawing editor's palette/toolbar
area, and to check whether it was already planned. It was **not**: confirmed
absent from `Orbit/Rebuild/` source (`grep` for `PhotosPicker`/`PHPicker`/
`UIImagePickerController` returned nothing) and only tracked as unscheduled
"legacy photo picker/crop/composite behavior" future work in
`docs/CLAUDE_CODE_CONTINUATION_BRIEF.md` and this worklog — not part of the
agreed near-term polish order. Implemented it now per the explicit request,
scoped to "import a photo to draw over," not legacy's full crop/composite flow.

Implementation (`DotNoteEntryEditors.swift`):

- `DrawingToolbar` gained a `photo.on.rectangle` button (PhotosUI's
  `PhotosPicker`) in the same row as the color swatches / pen-eraser toggle /
  undo, styled with the existing `DrawingIconButtonStyle`. `PhotosPicker`
  doesn't need `NSPhotoLibraryUsageDescription` for picker-only access (it runs
  out-of-process); the key already existed in `Info.plist` from legacy code
  regardless.
- `DrawingCanvasBoard` changed from a static `imageData: Data?` (decoded once)
  to `@Binding var image: UIImage?`, so a freshly picked photo shows live as a
  background layer behind the PencilKit canvas — plus a small circular "x"
  button (top-trailing) to clear it.
- `DrawingEditorView` loads the picked `PhotosPickerItem` via
  `loadTransferable(type: Data.self)` in `.onChange(of: photoPickerItem)`, and
  on save composites the photo + the live `PKDrawing` strokes into one image
  with `UIGraphicsImageRenderer` (a new `UIImage.aspectFitRect(in:)` helper
  mirrors `.scaledToFit()`'s centering so the saved result matches what was
  on screen). The composited image is what's written to `DotNoteEntry
  .imageData` — no `Domain`/`Store` model changes; a photo is just pixels in
  the same field a strokes-only drawing already used.
- Incidental bug fix found while wiring this up: the save button's `.disabled`
  check was `isSaving || draft.isEmpty`, where `draft.isEmpty` only looks at
  title/body text — a drawing with a photo and/or pencil strokes but no typed
  text could never be saved, before or after this change's photo feature.
  Fixed to also check `pickedImage == nil && canvasView.drawing.strokes
  .isEmpty`.

Confirmed via screenshot (`drawing-editor-photo-button`) that the icon renders
correctly in the toolbar. Did not exercise an actual photo selection in an
automated test — `PhotosPicker` opens the system Photos UI in a separate
process that XCUITest can't drive reliably against this environment's
simulator photo library, and the app's own accessibility identifiers don't
reach into it. Added a permanent assertion instead
(`testOpenDrawingFromSettingsCollection` now checks `drawing-photo-picker`
exists/hittable) to catch a regression in the button itself.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test suite: **all 15 passed**, no regressions.
- Visual: screenshots via the temporary-XCUITest-attachment method (see prior
  milestone) for all three editors, confirming both changes.

### Not done in this pass

- Actual end-to-end verification of "pick a real photo → draw over it → save →
  reopen and see both" was not performed (no reliable way to drive the system
  photo picker from this environment). The compositing logic
  (`composedImageData`) was reviewed carefully but should get a manual pass on
  a real device/simulator with photos before considering this fully verified.
- No crop/reposition/scale step for the imported photo (legacy had this); the
  photo is placed aspect-fit and centered, full stop. If precise placement
  matters, that's a follow-up.
- Dark-mode screenshots still not captured (same gap as the previous
  milestone).

Next up per the agreed order: settings and collection polish (item 3), then
light/dark preview coverage (item 4). The photo-import feature was pulled
forward from unscheduled future work at explicit request; legacy photo
crop/scale parity remains unscheduled.

---

## Milestone — Settings/collection header consistency (item 3 complete)

Commit: `b004a70` — "Unify settings sub-screen headers; remove
destructive-title string check"
Branch: `rebuild`. Status: **done, Dev test suite + Prod build verified,
confirmed visually via simulator screenshots.**

### What screenshots found

Real screenshots (not code reading) of Settings' four pushed sub-screens
(font list, help, license, diary/drawing/memo collection) showed each one's
back button rendering as a system-default **floating circular pill** at the
top-left, on its own row above the custom large title — visually different
from Settings root's own hand-built header, which pairs a small flat chevron
(no background) inline with the title in one row. Root cause: the four
sub-screens are pushed via `NavigationLink` inside Settings' `NavigationStack`
and never called `.navigationBarHidden(true)` or supplied a custom header, so
they fell back to the system nav bar — the same "raw system control breaks the
app's custom-header language" pattern as the diary/drawing date picker fixed
in an earlier milestone.

### Fix

Added `SettingsSubscreenHeader` (chevron button + `DotNoteType.wordmarkFont`
title, one row) and applied it plus `.navigationBarHidden(true)` to
`DotNoteFontListView`, `DotNoteHelpView`, `DotNoteLicenseView`, and
`DotNoteCollectionView`, matching `DotNoteSettingsView`'s own header exactly.
Back action is `@Environment(\.dismiss)` — `DotNoteFontListView` already used
this after picking a font, so the pattern was already proven in this codebase.

Also fixed while in the area: `DotNoteSettingsRow` picked its destructive
(red) title color by string-comparing `title == "모든데이터 삭제"`. Replaced
with an explicit `isDestructive: Bool = false` parameter.

### Test impact

`app.navigationBars.buttons.element(boundBy: 0).tap()` (used in
`testOpenSettingsSupportDestinations` to go back from Help) would have found
nothing once the nav bar was hidden — updated to tap the new
`subscreen-back-button` accessibility identifier instead, which all four
sub-screens now share (only one is ever on screen, so no ambiguity for tests).

### Incidental confirmation

The font list screenshot renders all 7 `DotNoteFontTheme` entries in their
actual custom faces (바른고딕/명조/바른펜/붓글씨/신비/플라워로드/록 each
visibly distinct) — a secondary visual confirmation that the PostScript-name
fix from an earlier milestone is holding.

### Verification

- `Orbit_Dev` full test suite: **all 15 passed**, no regressions.
- `Orbit_Prod` build: **BUILD SUCCEEDED** (checked because this touched
  navigation chrome broadly, not just one screen).
- Visual: screenshots of settings root, font list, diary collection, help,
  and license, before/after, via the temporary-XCUITest-attachment method.

### Not done in this pass

- Collection grid density/empty-slot layout when there's only 1 item in a
  2-column grid (currently just leaves the second column blank — looked fine
  in the screenshot, not treated as a defect).
- Dark-mode screenshots were not captured in this pass; item 4 was handled in
  the next appearance-mode milestone below.

All three original polish items (home, editors, settings/collection) are now
addressed. The follow-up appearance-mode milestone closes item 4 from the
original `docs/CURRENT_UI_BASELINE.md` → Next UI Work list.

## Milestone — Appearance mode setting + light/dark previews

User request: proceed with item 1 and add dark-mode switching in Settings.

### Scope

- Added `DotNoteAppearanceMode` (`system`, `light`, `dark`) to the domain
  settings model.
- Persisted the selected appearance mode through SwiftData via
  `DotNoteSettingsRecord.appearanceModeRawValue`.
- Applied the setting app-wide from `DotNoteRootView` using
  `.preferredColorScheme(...)`.
- Added a Settings appearance picker with three explicit choices:
  `시스템`, `라이트`, `다크`.
- Added light/dark SwiftUI preview coverage for:
  - `DotNoteRootView`
  - `CalendarHomeView`
  - `DotNoteSettingsView`
- Added shared in-memory preview fixtures in `DotNotePreviewData`.
- Updated unit/UI tests so settings persistence and the new Settings control are
  covered.

### Verification

- `git diff --check`: passed.
- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test suite: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped, 0 failures.
  - UI tests: 5 executed, 0 failures.

### Notes

- `appearanceModeRawValue` is optional in the SwiftData record so old persisted
  settings defensively fall back to `.system`.
- This was UI/domain-settings scoped only. No legacy Realm migration behavior
  changed.

## Milestone — Drawing photo placement controls

User request: continue the follow-up work for the drawing editor photo feature.

### Scope

- Added in-canvas photo adjustment state to `DrawingEditorView`.
- When a photo is selected, the editor now enters a photo adjustment mode.
- Added a `crop` toolbar button (`drawing-photo-adjust`) that toggles photo
  adjustment mode when a photo exists.
- While adjustment mode is active:
  - PencilKit input is temporarily disabled so the photo can receive gestures.
  - The photo can be dragged to reposition it.
  - The photo can be scaled from `0.5x` to `4x`.
  - A reset button (`drawing-photo-reset`) restores centered aspect-fit
    placement.
- Save compositing now uses the adjusted photo rect, so the saved `imageData`
  matches the visible photo placement plus PencilKit strokes.
- Fixed a related clear-photo bug: removing a photo and saving no longer falls
  back to the previously saved `imageData`.

### Verification

- `Orbit_Dev` build: **BUILD SUCCEEDED**.
- `Orbit_Dev` full test suite: **TEST SUCCEEDED**.
  - Unit tests: 12 executed, 1 skipped, 0 failures.
  - UI tests: 5 executed, 0 failures.

### Notes

- This keeps the feature in the existing SwiftUI/PencilKit editor instead of
  recreating the old UIKit "Move and Scale" crop screen.
- End-to-end PhotosPicker interaction with real library content still needs a
  manual simulator/device pass because the system photo picker is outside the
  app's own UI automation surface.

## Milestone — Legacy data migration validation

User request: proceed with data migration validation.

### Scope

- Reviewed the current legacy Realm import bridge and SwiftData store boundary.
- Added SwiftData end-to-end migration coverage for:
  - first app load importing a legacy snapshot into SwiftData,
  - preserving entries, settings, image data, text alignment, weather, and dates,
  - marking legacy import as complete,
  - preventing a second import on a later load.
- Tightened the import guard so legacy import only runs when SwiftData has no
  entry records and no settings record. This avoids mixing legacy data into an
  already-initialized SwiftData store.
- Added coverage for the edge case where SwiftData already has settings but no
  entries; legacy import is skipped and the existing settings are preserved.

### Verification

- `git diff --check`: passed.
- `Orbit_Dev` unit tests: **TEST SUCCEEDED**.
  - Unit tests: 14 executed, 1 skipped external Realm fixture, 0 failures.
- Synthetic Realm file import test passed:
  - `LegacyRealmImportTests.testLoadLegacySnapshotFromRealmFile`
  - This creates a temporary Realm file with legacy `Content` and `Settings`
    objects, then verifies the importer reads it correctly.
- Attempted external Realm fixture validation using simulator-discovered
  `default.realm` candidates, but XCTest did not receive
  `DOTNOTE_LEGACY_REALM_FILE` from the command environment in this run, so the
  external fixture test remained skipped.

### Notes

- No real legacy user `default.realm` file is committed or copied into the repo.
  Realm files may contain personal diary data and remain ignored by git.
- Before release, run the external fixture test with a real legacy app backup:
  `DOTNOTE_LEGACY_REALM_FILE=/path/to/default.realm xcodebuild test ...`
  or place a local ignored fixture at
  `OrbitTests/Fixtures/LegacyRealm/default.realm`.

---

## Milestone — Drawing photo-import e2e, light/dark visual pass, legacy UIKit reorg

Branch: `rebuild`. Status: **verification tasks done (no code changes needed);
legacy reorg committed as `9c02495`.**

Addresses the "Recommended Next Work" items from `docs/CLAUDE_CODE_CONTINUATION_BRIEF.md`
/ `docs/NEXT_SESSION_START.md` (items 1 and 3), plus the open "decide" item on
legacy UIKit screens (item 5).

### 1. Drawing photo-import end-to-end verification

Method: seeded the simulator's photo library with `xcrun simctl addmedia`, then
drove the real flow via a temporary XCUITest — open drawing editor → tap
`drawing-photo-picker` → tap a photo in the system PHPicker sheet (not in our
accessibility tree; tapped by normalized window coordinate) → draw a stroke →
save → reopen from home → confirm the composited image persisted.

**Confirmed working, reproduced 5+ times:** pick → canvas shows photo → save →
reopen shows the same photo. The core ask from the recommended-work list is
verified.

**Open, unresolved observation:** in one run, after drawing two consecutive
back-to-back strokes (second stroke's touch-down at the same point the first
one's touch-up ended), the photo disappeared from the canvas and stayed gone
after save/reopen — only the stroke persisted. Could not reliably reproduce
this with a single clean stroke across several follow-up attempts (both fast
and slow/held single drags left no photo loss, and in some attempts no visible
stroke was drawn at all — XCUITest's synthesized touch timing for PKCanvasView
is inconsistent in this environment). Not confirmed as a real app bug; could be
an XCUITest touch-synthesis artifact that doesn't reflect real finger input.
**Recommend a real-device/finger check**: pick a photo, draw two quick separate
strokes that start near where the previous one ended, save, reopen — confirm
the photo is still there.

Follow-up mitigation: `DrawingCanvasBoard` now only shows the photo clear
button while photo adjustment mode is active. The only normal code path that
sets `pickedImage` to `nil` is that clear button, so keeping it out of the
hit-test surface during pen drawing reduces the chance that quick synthesized
or real strokes near the top-right corner accidentally remove the photo.

### 2. Light/dark real visual pass

Set the simulator's system appearance directly (`xcrun simctl ui <device>
appearance dark`), relying on the app's default `.system` appearance mode, and
captured real screenshots (not Xcode canvas previews) of home, diary editor,
memo overlay, and Settings (including the new 화면 모드 시스템/라이트/다크
segmented picker added in `2009a9c`).

**Result: clean.** Warm dark palette holds up everywhere — no pure black
anywhere, diary/memo surfaces keep their tinted-dark variants, the weather
picker hairline affordance (from an earlier milestone) is visible in dark mode
too, amber "today" fill and accent colors keep their saturation. No contrast or
legibility issues found. This closes out the "real light/dark visual pass"
recommended-work item.

### 3. Legacy UIKit screens — decided: relocate now

Discussed the fate of the legacy UIKit source (previously only "should we keep
it" in the abstract). Verified via direct pbxproj inspection that **none of the
legacy view controllers/support files were in any active Sources build phase**
already — they were inert. Decision: move them into `Orbit/Legacy/` now (not
wait for migration verification) for repository clarity, since it's a pure
organization change with zero build/behavior risk. Full detail in the commit
message for `9c02495`; summary:

- Moved ~50 files (20 root-level legacy `.swift` files + `Delegate/`, `Util/`,
  `StoryBoard/`, `Option/` folders + the `Model` group) into `Orbit/Legacy/`
  via `git mv` (history preserved).
- Found and preserved one landmine: `Option/opensourceLicense.md` is **still
  actively read** by the current SwiftUI license screen
  (`Bundle.main.url(forResource:withExtension:)`). Extracted it out of the
  move and relocated it to `Orbit/opensourceLicense.md` instead, keeping its
  Resources build-phase membership untouched.
- pbxproj surgery: added one new `Legacy` PBXGroup and re-parented the
  existing group objects under it, rather than editing 50+ individual file
  `path` values — much lower risk given this project's documented history of
  "damaged project" from ID mistakes (see the pbxproj ID-collision note
  earlier in this file). New group ID `A10000000000000000000118`, grepped
  clean before use per that same lesson.
- The underlying legacy Realm model files (`DBModel.swift`, `Model.swift`,
  `RealmManager.swift`) were moved, **not deleted** — `REBUILD.md`'s
  non-negotiable against removing them before real `.realm` migration
  verification still applies. Confirmed before moving that
  `Rebuild/Migration/*` has its own independent legacy-schema definitions and
  does not import these files, so the move doesn't touch the active import
  bridge.

### Verification

- `Orbit_Dev` full test suite: **all 17 passed** (including the license-screen
  text assertion, which is a live proof `opensourceLicense.md` still loads
  correctly from its new location).
- `Orbit_Prod` build: **BUILD SUCCEEDED**.
- `xcodebuild -list` and `plutil -lint` both clean after the pbxproj edit.

### Not done in this pass

- The photo-loss observation above needs a real-device check to close out.
- Real legacy `.realm` migration verification was still waiting for a backup at
  this point, but the later product decision below supersedes that requirement.

---

## Milestone — Drawing toolbar selection polish

User decisions:

- There is no old Realm backup available, so migration validation should now be
  treated as current-app regression safety rather than a real-data import claim.
  Keep the synthetic Realm import and SwiftData migration tests passing, and
  verify the app does not malfunction when no external `.realm` file exists.
- Keep the current in-canvas photo placement UX. Do not recreate the legacy
  separate "Move and Scale" crop screen unless the product direction changes.
- Continue UI work by improving only the drawing color-selection and pen-width
  selection controls.

Implementation:

- Reworked the drawing toolbar color row from horizontally scrolling mixed
  controls into a fixed six-swatch row. Existing accessibility identifiers
  (`drawing-color-*`) are preserved for UI tests.
- Replaced the narrow pen-width slider/numeric value with five tappable width
  presets (`2`, `5`, `8`, `11`, `16`) rendered as stroke samples. The
  `drawing-line-width` identifier remains on the width-control group, with
  per-width identifiers added for future UI tests.
- Kept photo import, photo adjustment, eraser, and undo controls in a separate
  icon row so the color/width selections are easier to hit on a phone screen.
