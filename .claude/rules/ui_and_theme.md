---
paths:
  - "lib/**"
  - "example/lib/**"
  - "tool/**"
  - "test/**"
---
# Painting, Palette, Motion & Widget Standards

> **Parent Navigator:** [CLAUDE.md](../CLAUDE.md)  
> **Related Skills:** [`flutter-procedural-character`](../skills/flutter-procedural-character/SKILL.md), [`flutter-ui-advanced-graphics`](../skills/flutter-ui-advanced-graphics/SKILL.md), [`flutter-ui-theme-extensions`](../skills/flutter-ui-theme-extensions/SKILL.md), [`flutter-golden-tests`](../skills/flutter-golden-tests/SKILL.md)

---

## 1. Widget Decomposition & File Size Limits (Law 5)

- **Max File Size:** Keep every file within **150–200 lines**. A painter that grows past that is split by body part or by facing (`pipit_front_view.dart`, `pipit_feet.dart`), never into `_paintX()` helpers of one giant class.
- **No Builder Helpers:** `Widget _buildHeader()` inside a widget class is forbidden; extract a `StatelessWidget`. The same applies to the example app.
- **Modern Widget Constructors:** every widget declares a `const` primary constructor forwarding `super.key`: `class const PipitView({super.key, required final String id, ...}) extends StatefulWidget`.
- **One `StatefulWidget` per lifecycle concern.** `PipitView` is stateful because it owns a pose transition, pointer subscription and reactions; everything below it is a painter or a value. Do not add a second `State` for convenience.

---

## 2. Colours & the Palette (Law 3)

- **Painting code never names a colour.** A renderer takes a `PipitLook`; a look is built from a `PipitPalette` (`PipitLook.fromBody`, `PipitLook.of`). The only `Color(0x…)` literals in `lib/` are `PipitPalette.light` and `PipitPalette.dark`.
- **Derived, not duplicated.** Wing, mask, outline and band are derived from the body with `Color.lerp` so a user's single body colour can never clash. Add a derived colour before adding a palette slot.
- **Both palettes always.** A new palette slot gets a value in `light` and in `dark`, a field in `copyWith` and `lerp`, and a line in the README's colour section.
- **`PipitPalette.of(context)` is the only theme read.** It follows the theme's brightness when no extension is installed. Do not read `Theme.of(context).colorScheme` inside the package: the bird must look right in a non-Material tree too.
- **Example and tool may hold a few literals** (a ground colour behind the board), each with a reason; they are not shipped.

---

## 3. Deterministic Painting & Motion (Law 4)

- **Time and seed are arguments.** `paint()` reads no clock, `Random()`, or `DateTime.now()`. The bird's rhythm comes from `StableHash.seed(id)`; the moment comes from `PipitStage` through `seconds`. Same inputs, same pixels.
- **No allocation per frame.** `Path`s are built once per look and cached; `Paint` objects live on the renderer and only their colour changes; motion is `canvas.save/translate/rotate/scale`.
- **Repaint through a `Listenable`.** `CustomPainter(repaint: seconds)` repaints without rebuilding a widget. `setState` per frame is forbidden; `shouldRepaint` compares the look, facing, accessory, eyes and the spring target, never the current time (the `seconds` listenable is compared by identity).
- **One clock per screen.** `PipitStage` owns the single `Ticker`; it stops under `TickerMode(enabled: false)` and when the stage is disposed. A bird never creates its own `AnimationController`.
- **Springs, never cuts.** A new pose or expression is reached along `PipitPoseTransition` from wherever the bird is, so a rapid sequence of changes never jumps. Reactions (hop, squash) are impulses layered on top.
- **Reduced motion is honoured.** When `MediaQuery.disableAnimationsOf(context)` is true, idle motion freezes in its rest pose; pose changes still show without the tween. Without `seconds` a bird is a still picture.

---

## 4. Accessibility, Input & Layout

- **Semantics are mandatory.** Every `PipitView` has a `semanticLabel` (required parameter); a tappable bird is a `button`, otherwise an `image`. Do not add a parameter that makes the label optional.
- **Pointer feedback is cheap.** Hover and tap set an impulse and retarget the spring; they never rebuild the subtree. The pointer is read from the stage's `ValueListenable<Offset?>`, not from per-bird `MouseRegion` hit-testing of neighbours.
- **The bird fits its box.** All geometry is in units of the body; `size` is only a canvas scale, and every view and accessory stays inside `PipitRenderer.bounds` (the test `every view and accessory stays inside the shared bounds` guards this).
- **`RepaintBoundary` around each bird** so a crowd repaints only the birds that changed. See [`flutter-canvas-batch-rendering`](../skills/flutter-canvas-batch-rendering/SKILL.md) when a screen holds more than a few dozen.

---

## 5. Tests for Visible Things

- **A visible change gets a test:** a geometry bound, a golden, or a pixel-alpha probe like the existing bounds test. Pure motion (idle, blink timing, spring) is tested as pure Dart with fixed inputs.
- **Goldens at fixed seconds and both palettes**, following [`flutter-golden-tests`](../skills/flutter-golden-tests/SKILL.md). The README picture in `tool/` is a golden too; update it deliberately, never to make a run green.
- **Extension naming:** any public Dart extension is suffixed with `X` (`PipitPoseX`), never `...Extension`.
