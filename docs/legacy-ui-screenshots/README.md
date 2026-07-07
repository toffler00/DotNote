# Legacy UI Inventory (Live App Capture)

Primary visual reference for the Claude design pass. These are runtime captures
of the **real, installed App Store build** of Dot Note (the old UIKit app),
so they are ground truth for appearance and motion — more accurate than the
storyboard/source reconstruction described in `LEGACY_UI_SCREENSHOT_PLAN.md`.

- Captured: iPhone (1179×2556, portrait), Korean locale, light mode, Oct 2021 data.
- Screenshots: this folder.
- Walkthrough video (~112s): `../legacy-ui-recordings/dotnote-walkthrough.mp4`.

> Use these for *how it looks and feels*. Use the source-derived facts in
> `CLAUDE_UI_REDESIGN_HANDOFF.md` for exact color hex, font file names, asset
> names, and screen hierarchy. The two are complementary — neither replaces the
> other.

## Brand palette (sampled from captures)

| Token (proposed) | Hex | Where |
| --- | --- | --- |
| Background / paper | `#FFFFF0` | App-wide warm ivory. The signature surface. |
| Ink / dark accent | `~#2F2422` | "Today" circle fill, calendar month header band, primary text. Near-black warm espresso, **not** pure black. |
| Diary editor body | `#F6FCE2` | Pale green-tinted writing area (distinct from ivory). |
| Drawing canvas | `#FFFFFF` | Pure white, only inside the drawing-diary canvas. |
| Faded / disabled | light warm gray | Out-of-month calendar days, placeholder text. |
| Destructive | iOS system red | "모든데이터 삭제" row. |

Typography: the **`Dot Note` wordmark and all screen titles use a dotted/stippled
display font** (custom Korean handwriting fonts under `Orbit/*.ttf` / `*.otf`).
This dotted-outline title treatment is the strongest brand signature. Body/date
text uses a plain sans/serif. Font choice is user-configurable (Settings → 폰트).

## Screens

### 01 — Main calendar, create button collapsed
`01-main-calendar-collapsed.png`
- Layout top→bottom: status bar → `⋯` overflow (top-right) → large `Dot Note`
  dotted wordmark with a `<` chevron (collapse/expand toggle for create actions)
  → dark month header band (`Oct 2021`) → weekday row (일~토) → month grid.
- Today (the 1st) = dark filled circle with an underline tick. Out-of-month days
  faded. No entry data shown on this date, so no per-day markers visible here.
- **Calendar-first mental model.** This is the home screen.

### 02 — Main calendar, create actions expanded
`02-main-calendar-actions-expanded.png`
- Same screen; the `<` chevron expanded into an inline action row next to the
  wordmark: **메모 (memo)**, **그림일기 (drawing diary)**, **일기 (diary)**, each an
  outlined icon + label, with a `>` to collapse.
- This is the primary create affordance — an expandable button row, not a FAB.

### 03 — Diary write (일기)
`03-write-diary.png`
- Back `<`, dotted title `일기`, top-right ✓ (checkmark = save/confirm).
- Header block: weekday (`Friday`), date row `01 Oct 2021 >` (tappable date
  picker), `날씨를 선택하세요 >` (weather picker row).
- Title field placeholder `제목을 쓰윽쓰윽` with a camera icon on the right (attach photo).
- Large body area, placeholder `글을 입력하세요`, on the pale-green editor surface.
- (Video shows a weather picker: 맑음 / 천둥번개 / 이슬비 / 눈·비, and text alignment
  controls — left/center/right — above the keyboard.)

### 04 — Drawing diary write (그림일기)
`04-write-drawing-diary.png`
- Similar header (`그림 일기` dotted title, ✓ save). Date `2021.10.01.Fri`, `날씨`.
- Title placeholder `제목은 여기에`.
- **White square drawing canvas** (PencilKit-style) as the centerpiece, with a
  body text area (`글을 입력하세요`) below on the pale-green surface.
- (Video shows: photo picker `나의 사진` grid → pick photo → draw over it with a
  color palette + undo/share/camera toolbar; image "Move and Scale" crop step.)

### 05 — Memo write (메모 overlay)
`05-write-memo.png`
- Presented as a **centered card overlay** over a dimmed calendar (modal, not full screen).
- Card: date header `2021.10.01 Fri` + `✕` close; large blank note area; a small
  torn-note/paper illustration near the bottom.
- Lightest-weight entry type: date + freeform text, no title/weather/photo.

### 06 — Settings (설정)
`06-settings.png`
- Dotted title `설정`, back `<`. Grouped list:
  - **테마**: 폰트 (font picker — the theme system)
  - **모아보기**: 메모보기, 일기보기 (collection views per entry type)
  - **지원**: 의견보내기, Dot Note 사용법, Open-source License
  - **데이터삭제**: 모든데이터 삭제 (destructive, red)

## Flows observed in the walkthrough video

- Month navigation (swipe/paginate between months, e.g. Oct↔Nov 2021).
- Create flow: expand action row → choose 메모 / 그림일기 / 일기 → editor → ✓ save.
- Diary: pick date, pick weather, type title/body, choose text alignment.
- Drawing diary: pick a photo from library → crop (Move and Scale) → draw/annotate
  over it with color palette → save.
- Settings → 폰트 changes the app-wide typography (font theme).
- Collection views (`나의 일기` / memo collection) list saved entries with their
  photo + drawing composited together.

## Coverage vs. gaps

Captured: main (collapsed + expanded), diary editor, drawing editor, memo overlay,
settings. Video additionally covers weather picker, font picker, photo pick + crop,
drawing palette, and collection views.

Not yet captured as still screenshots (exist in video only — extract frames if a
static reference is needed):
- Weather picker sheet
- Font/theme picker screen
- Photo picker grid + "Move and Scale" crop
- Collection views (메모보기 / 일기보기) populated
- Tutorial / onboarding pages
- Populated calendar showing per-day entry markers

## Filename ↔ original mapping

| Repo file | Original (from capture zip) |
| --- | --- |
| `01-main-calendar-collapsed.png` | 메인화면_캘린더화면1.png |
| `02-main-calendar-actions-expanded.png` | 메인화면_캘린더화면2.png |
| `03-write-diary.png` | 일기작성화면.png |
| `04-write-drawing-diary.png` | 그림일기작성화면.png |
| `05-write-memo.png` | 메모작성화면.png |
| `06-settings.png` | 설정화면.png |
| `../legacy-ui-recordings/dotnote-walkthrough.mp4` | dotnote_구동영상.mp4 |
