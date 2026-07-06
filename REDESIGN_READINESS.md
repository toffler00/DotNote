# Redesign Readiness Checklist

This document is a set of **guardrails for the current modernization work**.

The app will be handed to a Claude-driven design pass *after* the functional
SwiftUI rebuild is complete. That pass starts as a visual restyle but may grow
into UX/flow redesign and brand redefinition. None of that happens now.

The modernization work (iOS version, open-source dependencies, database) is
**not** a design task, so most of this is "do no harm." The goal here is simply
to make sure the choices made now do not paint the future redesign into a
corner. Keep these in mind while working; they are cheap now and expensive later.

## Guiding principle

The redesign must be able to touch **View files only**. Anything that leaks
presentation decisions into the data/logic layer, or hardcodes a specific
visual style into persisted data, becomes a migration problem during redesign.

---

## Guardrails to follow now (during modernization)

- [ ] **Keep view/logic separation strict.** No storage, migration, filtering,
      or networking logic inside SwiftUI `View` bodies. Route everything through
      `DotNoteAppModel` and the `DotNoteStore` boundary (already established —
      just don't regress it).
- [ ] **Persist semantic values, not presentation values.** Store *what* a thing
      is, not *how* it looks. Enum raw values, dates, and content are fine.
      Do not persist colors, hex strings, point sizes tied to a specific layout,
      pixel offsets, or theme-specific style names as bare data.
- [ ] **Treat `DotNoteSettings` font fields as a wrapping point, not final API.**
      `navigationTitleFontName` / `contentTitleFontName` / `bodyFontName` are
      raw `String` today. The custom Korean handwriting fonts are the current
      brand identity and are a live redesign decision (keep handwriting vs. go
      modern). If any typed abstraction is introduced, wrap these strings behind
      an enum/type (e.g. `DotNoteFontTheme`) so the brand decision does not force
      a data migration later. Do not spread raw font-name strings through new
      code.
- [ ] **Do not bake navigation/flow assumptions into models or the store.**
      The redesign may invert the primary flow (e.g. calendar-first vs.
      list-first). Keep `DotNoteEntry` / `DotNoteStore` agnostic to how screens
      are arranged or navigated.
- [ ] **Keep `collectionFilter: Int` decoupled from UI.** It is a legacy magic
      number. Don't build new UI logic that assumes specific integer meanings;
      if you touch it, map it to a named enum at the boundary.
- [ ] **Any new asset/icon should be nameable, not positional.** When wiring
      weather icons, alignment icons, etc., reference them by semantic name so a
      redesign can swap the asset without code changes.

## Deliberately deferred to the redesign pass (do NOT do now)

- Introducing an app-wide color palette, spacing scale, or component library.
- Restyling the migration/preview screens (they are throwaway).
- Choosing final typography, dark-mode treatment, or app icon.
- Any "make it look nice" work. Ship functional-but-plain screens.

A thin design-token entry point (e.g. a `DotNoteTheme` file mapping to system
defaults) is acceptable if it helps organize code, but it must stay minimal.
Do not invest in a specific visual style now — it will be replaced.

---

## Handoff checklist (redesign can begin when all true)

- [ ] All legacy feature screens exist in SwiftUI: List, Write, Diary, Memo,
      Drawing, Photos, Calendar, Options/Theme settings, Tutorial.
- [ ] Each screen runs and is verified in the simulator with real/imported data.
- [ ] Each screen has a SwiftUI `Preview` backed by sample fixtures
      (e.g. `DotNoteEntry.sampleDiary` / `.sampleMemo` / `.sampleDrawing`) so
      screens render without a live database.
- [ ] Legacy UIKit app screenshots are captured as "before" reference.
- [ ] Realm → SwiftData import is verified end-to-end (no data-loss risk before
      styling work begins).

## Redesign execution order (for reference, not for now)

Brand/mood agreement (mockups) → design tokens → shared components → per-screen
restyle → (if scope grows) UX/flow rework.
