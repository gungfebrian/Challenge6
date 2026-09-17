# Calm Guardian UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the existing spam checker into a lively, focused iOS demo built around one message-shield mascot and the flow “paste → check → understand.”

**Architecture:** Preserve MVVM, Core ML, SwiftData, and the three-tab shell. Replace the dense Check form with identity/input/action zones, present successful results in a focused sheet, and align secondary tabs through shared semantic styling.

**Tech Stack:** SwiftUI, SF Symbols, Dynamic Type, SwiftData, Core ML, asset catalogs, built-in image generation; no third-party dependencies.

**Spec:** `docs/superpowers/specs/2026-09-18-calm-guardian-ui-design.md`

## Global constraints

- Target Xcode 26.6 and iOS 26.5.
- Preserve model output, history semantics, privacy, settings keys, and metadata.
- Keep one primary action and three dominant visual groups per screen/state.
- Use original artwork, system typography, semantic colors, 44-point controls, Dynamic Type, VoiceOver, and Reduce Motion.
- Demo examples are walkthrough inputs, not training records.

---

### Task 1: Record the approved design

- [x] Create the design spec and this tracked plan.
- [x] Run `git diff --check`.
- [x] Commit as `docs: define the calm guardian UI redesign`.

### Task 2: Generate mascot and icon assets

- [x] Generate and inspect idle, checking, safe, and warning mascot PNGs with transparent backgrounds.
- [x] Generate and inspect standard, dark, and tinted opaque 1024-pixel app icons.
- [x] Add image sets and validate size/alpha with `sips`.
- [x] Commit as `design: add the guardian mascot and app icon`.

### Task 3: Add visual primitives

- [x] Add semantic theme, sky background, app card, primary button style, and animated mascot view.
- [x] Add 12-point spacing and previews for both appearances and large text.
- [x] Build the simulator target.
- [x] Commit as `design: add calm guardian visual primitives`.

### Task 4: Rebuild the Check experience

- [x] Replace the grouped form with the three-zone layout.
- [x] Add the single example, help, and result sheet coordinator.
- [x] Preserve cancellation, stale-result checks, persistence warnings, haptics, announcements, focus, and error recovery.
- [x] Add idle/loading/result/failure previews and verify the focused checks/build.
- [ ] Commit as `feat: focus the spam check experience`.

### Task 5: Align History, Settings, and navigation

- [ ] Preserve all native navigation, list, form, deletion, and settings behavior.
- [ ] Apply semantic backgrounds, surfaces, typography, and tint.
- [ ] Use the mascot only for the History empty state.
- [ ] Commit as `design: align history and settings with the guardian theme`.

### Task 6: Verify the demo

- [ ] Update `docs/academy-demo-guide.md` for the new flow.
- [ ] Run focused checks and a generic Simulator build.
- [ ] Capture light/dark screenshots and inspect small/large phones, iPad, landscape, keyboard, large text, VoiceOver order, and Reduce Motion.
- [ ] Run `git diff --check` and review repository status.
- [ ] Commit as `docs: refresh the calm guardian demo walkthrough`.
