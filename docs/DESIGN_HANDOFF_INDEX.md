# Dot Note — Design Handoff Index

Single entry point for the Claude design pass. Read this first, then follow the
links in order.

## What this project is

Reviving the legacy **Dot Note** iOS app (a calendar-first Korean journaling app:
diary / memo / drawing-diary entries, custom handwriting fonts) as a modern
SwiftUI app. The data/structure rebuild is done or in progress; the UI is still
a scaffold. Your job is the visual/interaction redesign.

## Read in this order

1. **[CLAUDE_UI_REDESIGN_HANDOFF.md](CLAUDE_UI_REDESIGN_HANDOFF.md)** — current
   rebuild state, SwiftUI file map, build/test commands, next UI work. Start here.
2. **[legacy-ui-screenshots/README.md](legacy-ui-screenshots/README.md)** —
   annotated inventory of the old app: per-screen anatomy, sampled color palette,
   observed flows, and coverage gaps. The visual ground truth.
3. **[legacy-ui-recordings/dotnote-walkthrough.mp4](legacy-ui-recordings/dotnote-walkthrough.mp4)**
   — ~112s runtime walkthrough. Motion, transitions, and flows (weather picker,
   font picker, photo pick + crop, drawing palette, collection views).
4. **[../REDESIGN_READINESS.md](../REDESIGN_READINESS.md)** — guardrails you must
   follow. Short version: change **View files only**, keep storage/migration/
   filtering logic out of views, and never hardcode design tokens into the data
   layer.
5. **[LEGACY_UI_SCREENSHOT_PLAN.md](LEGACY_UI_SCREENSHOT_PLAN.md)** — where to
   find exact color hex, font file names, and asset names from the source when a
   screenshot is not enough.

## Scope

Starts as a **visual restyle**. May grow into **UX/flow redesign** and **brand
redefinition** (including whether to keep the custom Korean handwriting fonts,
which are the current brand signature). Confirm direction before large moves.

## Brand cues to preserve unless deliberately changed

- Warm ivory paper background `#FFFFF0`, warm near-black ink `~#2F2422`.
- Dotted/stippled display font for the `Dot Note` wordmark and screen titles.
- Calendar-first home; expandable create-action row (memo / drawing-diary / diary).
- Three entry types with distinct surfaces (diary = pale green, drawing = white canvas).

## Execution order

Brand/mood agreement (mockups) → design tokens (`DotNoteTheme`) → shared
components → per-screen restyle → (if scope grows) UX/flow rework.

## Do not start until

The functional SwiftUI screens exist and are simulator-verified (see the Handoff
checklist in `../REDESIGN_READINESS.md`). Redesigning a scaffold is wasted work.
