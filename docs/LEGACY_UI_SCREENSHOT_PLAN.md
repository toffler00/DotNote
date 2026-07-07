# Legacy UI Screenshot Plan

This document explains how to gather old Dot Note UI screenshots for the
redesign pass.

> **Status (obtained):** Live runtime captures of the real installed App Store
> build are now in `docs/legacy-ui-screenshots/` (6 screenshots) and
> `docs/legacy-ui-recordings/` (walkthrough video). See
> [`docs/legacy-ui-screenshots/README.md`](legacy-ui-screenshots/README.md) for
> the annotated inventory and sampled palette. The "Best Option" below has been
> fulfilled; the remaining gaps (weather/font pickers, collection views,
> tutorial) live in the video and can be frame-extracted if stills are needed.

## Current Reality

The legacy UIKit source files and storyboards are still in the repository, but
the active app on the `rebuild` branch now launches the SwiftUI rebuild path.
That means we cannot simply run the current app and see the old UI.

So there are three possible screenshot sources:

1. Real screenshots from an installed old App Store/TestFlight build.
2. A temporary legacy-capture branch that re-enables the old UIKit app launch.
3. Static storyboard/reference screenshots from Xcode or generated previews.

## Best Option: Real Installed App Screenshots

If an old version of Dot Note is installed on a device or simulator, capture:

- Main calendar/list screen
- Create action expanded state
- Diary write screen
- Memo overlay
- Diary detail screen
- Drawing diary screen
- Photo picker/attached photo flow
- Options/settings screen
- Theme/font settings
- Tutorial/onboarding pages
- Empty state and populated state

Recommended viewport:

- iPhone 15/16/17 class portrait
- Light mode
- Korean locale if that was the original primary locale

Store screenshots under:

```text
docs/legacy-ui-screenshots/
```

Suggested names:

```text
01-main-calendar-list.png
02-create-actions-expanded.png
03-write-diary.png
04-memo-overlay.png
05-diary-detail.png
06-drawing-diary.png
07-options.png
08-theme-settings.png
09-tutorial-page.png
```

## Best Repository-Based Option: Temporary Legacy Capture Branch

Create a temporary branch from a commit before the SwiftUI launch switch or
temporarily re-enable the old UIKit `AppDelegate`/storyboard path.

Purpose:

- Only for screenshot capture.
- Do not merge this branch into `rebuild`.
- Do not modernize dependencies there unless required to launch far enough for screenshots.

Likely blockers:

- Old CocoaPods dependencies were removed on `rebuild`.
- Some legacy dependencies are obsolete or may not compile under current Xcode.
- Fabric/Crashlytics scripts and old pods should stay disabled if possible.

Useful legacy files:

- `Orbit/AppDelegate.swift`
- `Orbit/StoryBoard/Base.lproj/Main.storyboard`
- `Orbit/StoryBoard/TutorialPageView.storyboard`
- `Orbit/ListViewController.swift`
- `Orbit/WriteViewController.swift`
- `Orbit/MemoViewController.swift`
- `Orbit/DiaryViewController.swift`
- `Orbit/DrawingDiaryViewController.swift`
- `Orbit/Option/OptionsViewController.swift`

## Static Reference Option

Even without launching the old app, the repository has enough UI material to
create a static design reference board:

- Storyboards show some base layout structure.
- UIKit view controllers show programmatic layout, colors, fonts, and flows.
- Asset catalogs include the original iconography and launch image.
- Fonts remain in the app folder.

This option is useful for early redesign direction, but it is less accurate
than runtime screenshots because many important old screens were built
programmatically rather than fully visible in storyboard.

## What Can Be Captured Immediately From This Repository

Immediately available:

- Launch screen visual from `Orbit/Base.lproj/LaunchScreen.storyboard`
- Tutorial image assets from `Orbit/Assets.xcassets/tutorial*.imageset`
- App icons and original weather/action icons
- Static storyboard structure for:
  - Root navigation/list controller
  - Diary detail storyboard scene
  - Options storyboard scene
  - Tutorial page view controller

Not immediately available as accurate runtime screenshots:

- Main calendar populated with real data
- Expandable create action animation/state
- Memo overlay presentation
- Programmatic diary write layout
- Drawing canvas behavior
- Settings cells populated with real fonts/options

## Recommendation

For the redesign pass, use both:

1. Real or temporary-branch runtime screenshots as primary visual references.
2. This repository's UIKit code and assets as secondary references for behavior,
   hierarchy, and original brand cues.

Until real legacy screenshots are available, the next best step is to create a
static UI inventory from the old UIKit files and assets, then design the modern
SwiftUI screens against that inventory.
