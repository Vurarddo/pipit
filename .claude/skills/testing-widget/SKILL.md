---
name: testing-widget
description: "Widget tests for an animated canvas widget with flutter_test alone: driving a ValueNotifier clock, pump vs pumpAndSettle, semantics finders, hover and tap reactions, rendering a painter to pixels. Use when testing PipitView, PipitStage or a painter."
metadata:
  category: testing
---

# Widget Testing Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Testing `PipitView` or `PipitStage` behaviour: semantics, `seconds: null` stillness, reduced motion, `TickerMode`, hover hop, tap squash, pointer following.
- Rendering a painter to an image and probing pixels (alpha inside and outside the shared bounds).
- Avoiding the classic trap: `pumpAndSettle()` on a stage that ticks forever.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [testing-hub](../testing-hub/SKILL.md) | What each test layer proves and where it lives. |
| **Goldens** | [flutter-golden-tests](../flutter-golden-tests/SKILL.md) | Pinning the picture once a widget test passes. |
| **The painter** | [flutter-procedural-character](../flutter-procedural-character/SKILL.md) | Why time is an argument, which makes these tests possible. |

---

## 3. Driving Time

| Method | Behaviour | Use for |
| :--- | :--- | :--- |
| `await tester.pump()` | One frame. | Settling a `setState`, a `didUpdateWidget`, a semantics change. |
| `await tester.pump(Duration)` | Advances the fake clock; a live `PipitStage` ticks. | Letting a spring or reaction progress a known amount. |
| `seconds.value = t` on your own `ValueNotifier<double>` | Moves the bird to an exact moment without a stage. | Deterministic frames, pixel probes, goldens. |
| `await tester.pumpAndSettle()` | Pumps until no frame is scheduled. | **Never with a live stage**: it never settles. Only for widgets without a ticker. |

> [!CAUTION]
> Prefer passing your own `ValueNotifier<double>` as `seconds` over wrapping the subject in `PipitStage`. The stage is tested once for its own contract (ticking, stopping, pointer); every other test pins time by hand.

---

## 4. Patterns

- **Own the surface:** `tester.view.physicalSize = const Size(w, h); tester.view.devicePixelRatio = 1; addTearDown(tester.view.reset);` so a 120 px bird is 120 px.
- **Minimal tree:** `Directionality(textDirection: TextDirection.ltr, child: Center(child: PipitView(...)))`. No `MaterialApp` unless the test is about `PipitPalette.of(context)` following the theme; then `MaterialApp(theme: ThemeData(brightness: ...))`.
- **Find by semantics**, not by type: `find.bySemanticsLabel('Robin the bird')`; assert `button` vs `image` flags with `tester.getSemantics`.
- **Hover and tap:** `final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse); await gesture.addPointer(); addTearDown(gesture.removePointer); await gesture.moveTo(tester.getCenter(finder));` then pump a few frames and assert the reaction through the painter's inputs or a pixel probe. Tap with `tester.tap(finder)`.
- **Pixels:** draw with `PictureRecorder` → `Canvas` → `PipitRenderer().paint(...)` → `toImage(px, px)` → `toByteData()`, then read `rgba[(y * px + x) * 4 + 3]` for alpha. The existing bounds test in `test/pipit_test.dart` is the template.
- **Reduced motion:** wrap in `MediaQuery(data: const MediaQueryData(disableAnimations: true), child: ...)` and assert the picture does not change between two pumps.
- **`TickerMode`:** `TickerMode(enabled: false, child: PipitStage(...))` must not advance `seconds`.

---

## 5. Anti-Patterns

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| `pumpAndSettle()` under a live `PipitStage` | **CRITICAL** | Drive `seconds` yourself or pump fixed durations. |
| Asserting on `DateTime.now()`-dependent output | **CRITICAL** | Fixed `id`, fixed `seconds`, named palette. |
| Finding `CustomPaint` by type and reading private fields | **HIGH** | Assert through semantics, pixels, or the public inputs. |
| Leaving a `ValueNotifier` or gesture undisposed | **MEDIUM** | `addTearDown(notifier.dispose)`, `addTearDown(gesture.removePointer)`. |

---

## 6. Verification Checklist

- [ ] No `pumpAndSettle()` while a stage is ticking.
- [ ] Time is pinned by a `ValueNotifier<double>` or fixed pump durations.
- [ ] Finders use semantics labels; semantics flags asserted for tappable vs still birds.
- [ ] Surface size and pixel ratio set, reset in `addTearDown`.
- [ ] Everything created is disposed; no new dev dependency.
