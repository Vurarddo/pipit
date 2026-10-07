---
name: flutter-ui-hub
description: "Entry point for UI work on the Pipit package: painting the bird, its motion, its widget and its palette. Use when drawing, animating or changing PipitView, the renderer, a pose or an accessory; routes to graphics, motion, performance and tests."
metadata:
  category: presentation
---

# Pipit UI Coordinator Hub

## 1. Overview & Package UI Laws

Pipit's whole UI is one widget (`PipitView`), one clock (`PipitStage`) and the painting behind them. This hub routes any UI task to the skill that covers it and restates the laws that apply to every one of them (full text in [ui_and_theme.md](../../rules/ui_and_theme.md)).

### Core UI Rules (per `CLAUDE.md`):
1. **Size limits (Law 5):** every file within 150–200 lines; a painter is split by body part or facing, never into `_paintX()` / `_buildX()` helpers.
2. **Colours from the palette (Law 3):** painting code takes a resolved `PipitLook`; the only colour literals in `lib/` are the two `PipitPalette` constants.
3. **Deterministic painting (Law 4):** time and seed are arguments; nothing is allocated per frame; repaint through the stage's `Listenable`, never `setState`.
4. **Springs, not cuts:** a new pose, expression or pointer target is reached along `PipitPoseTransition`; reactions are impulses on top.
5. **Accessible by default:** `semanticLabel` is required; a tappable bird is a button, otherwise an image; reduced motion and `TickerMode` are honoured.

---

## 2. UI Skill Tree & Routing Matrix

| Task | Target Skill | Purpose |
| :--- | :--- | :--- |
| **Drawing the bird** | [flutter-procedural-character](../flutter-procedural-character/SKILL.md) | Unit geometry, part layers, poses, idle from one ticker, reactions. The core skill of this package. |
| **Canvas foundations** | [flutter-ui-advanced-graphics](../flutter-ui-advanced-graphics/SKILL.md) | `CustomPainter`, `Path`, `shouldRepaint`, `RepaintBoundary`, spring simulations. |
| **Motion & transitions** | [flutter-ui-animations](../flutter-ui-animations/SKILL.md) | Implicit vs explicit animation, staggering, many birds moving across a screen. |
| **Crowds of birds** | [flutter-canvas-batch-rendering](../flutter-canvas-batch-rendering/SKILL.md) | Hundreds of birds in one painter: atlases, levels of detail, culling, hit-testing. |
| **Placing many birds** | [dart-procedural-world-layout](../dart-procedural-world-layout/SKILL.md) | Deterministic, non-overlapping placement, wandering and gathering on a drawn surface. |
| **The palette** | [flutter-ui-theme-extensions](../flutter-ui-theme-extensions/SKILL.md) | `PipitPalette` as a `ThemeExtension`: slots, `lerp`, `copyWith`, light and dark. |
| **Widget lifecycle** | [flutter-ui-stateless-stateful](../flutter-ui-stateless-stateful/SKILL.md) | `didUpdateWidget`, `didChangeDependencies`, disposing listeners, const trees. |
| **Layout errors** | [flutter-fix-layout-issues](../flutter-fix-layout-issues/SKILL.md) | Unbounded constraints and overflow in the example app or a user's tree. |
| **Frame cost** | [performance-hub](../performance-hub/SKILL.md) | Profiling a crowd, `saveLayer` cost, rebuild scope. |
| **Pinning the picture** | [testing-hub](../testing-hub/SKILL.md) | Widget tests, goldens at fixed seconds, the README screenshot. |
| **Constructors** | [dart-use-primary-constructors](../dart-use-primary-constructors/SKILL.md) | `class const PipitView({super.key, ...}) extends StatefulWidget`. |

---

## 3. Package UI Layout

```text
lib/src/
├── pipit_view.dart            # The widget: semantics, pointer following, tap/hover reactions
├── pipit_stage.dart           # One Ticker per screen; seconds and pointer as ValueListenables
├── pipit_painter.dart         # CustomPainter(repaint: seconds); composes the pieces below
├── pipit_renderer.dart        # Paints one bird at one motion; owns PipitRenderer.bounds
├── pipit_front_view.dart, pipit_side_view.dart, pipit_back_view.dart   # One painter per facing
├── pipit_geometry.dart, pipit_gear_geometry.dart                       # Unit geometry
├── pipit_face.dart, pipit_feet.dart, pipit_headwear.dart, pipit_accessories.dart, pipit_ink.dart
├── pipit_motion.dart          # Idle: breath, blink, lean, seeded by the bird's id
├── pipit_pose.dart, pipit_pose_transition.dart, pipit_reactions.dart   # Poses, the spring, impulses
└── pipit_look.dart, pipit_palette.dart                                  # Colours
```

Everything the user sees is exported by `lib/pipit.dart`; the painters and geometry are not.

---

## 4. Workflow for a Visible Change

1. Decide whether it is **geometry** (a part, an accessory, a facing), **motion** (a pose, a reaction, idle) or **API** (a parameter, a palette slot). Open the matching file; do not grow `pipit_view.dart`.
2. Keep geometry in units of the body; `size` is only a scale. Check the result stays inside `PipitRenderer.bounds`.
3. Run `flutter test` (the bounds and motion tests), then the goldens if the picture changed.
4. Redraw `doc/pipit.png` with `flutter test tool/screenshot_test.dart --update-goldens` and look at it.
5. Document the new parameter or value in `///` comments, `README.md` and `CHANGELOG.md`.

---

## 5. Master UI Verification Checklist

- [ ] File size under 150–200 lines; no `_buildX()` or `_paintX()` helpers on one giant class.
- [ ] No colour literal outside `PipitPalette.light` / `PipitPalette.dark`.
- [ ] `paint()` allocates nothing and reads no clock or random source.
- [ ] Every view and accessory stays inside the shared bounds (test passes).
- [ ] Reduced motion and `TickerMode` still freeze the bird; `seconds: null` is a still picture.
- [ ] Goldens and `doc/pipit.png` updated deliberately, both palettes.
- [ ] README and CHANGELOG mention the change if it is visible to users.
