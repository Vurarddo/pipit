---
name: performance-hub
description: "Entry point for frame cost in the Pipit package: a crowd of birds, paint cost per frame, rebuild scope, profiling with DevTools. Use when a screen of birds drops frames or before accepting a change to the painter."
metadata:
  category: performance
---

# Performance Hub

## 1. Overview & Where the Cost Is

A bird is one `CustomPaint` repainted every frame by the stage's ticker. The budget is therefore **paint cost × number of birds**, plus whatever the host app rebuilds around them. There is no network, no parsing and no list virtualisation to tune; the levers are the ones below.

```mermaid
graph TD
    A["Dropped frames on a screen of birds"] --> B{"Where?"}
    B -->|Raster / paint thread| S1["performance-expensive-operations<br/>saveLayer, clips, shadows, opacity"]
    B -->|UI thread, build()| S2["performance-rendering-build<br/>rebuild scope, const, AnimatedBuilder child"]
    B -->|Too many birds| S3["flutter-canvas-batch-rendering<br/>one painter, atlas, levels of detail"]
    B -->|Motion itself| S4["flutter-ui-animations<br/>springs, staggering, disposal"]
```

---

## 2. Master Routing Matrix

| Symptom | Target Skill | Levers |
| :--- | :--- | :--- |
| **Raster thread over budget** (paint cost) | [performance-expensive-operations](../performance-expensive-operations/SKILL.md) | No `saveLayer`, no `Opacity` widget over a painter, clip only when needed, cached `Path`s, `Paint` reuse. |
| **UI thread over budget** (rebuilds) | [performance-rendering-build](../performance-rendering-build/SKILL.md) | Repaint through `repaint:`, never `setState` per frame; `const` subtrees; `RepaintBoundary` per bird. |
| **Dozens to hundreds of birds** | [flutter-canvas-batch-rendering](../flutter-canvas-batch-rendering/SKILL.md) | One painter for the crowd, sprite atlas, levels of detail, culling, spatial-grid hit tests. |
| **Motion looks heavy** | [flutter-ui-animations](../flutter-ui-animations/SKILL.md) | One ticker per screen, springs retargeted not restarted, `TickerMode` stops hidden screens. |
| **The painter itself** | [flutter-procedural-character](../flutter-procedural-character/SKILL.md) | Geometry as data, no per-frame allocation, time as an argument. |

---

## 3. Profiling

1. **Profile mode, real device or Chrome.** `cd packages/pipit/example && flutter run --profile -d chrome` (or a device). Debug mode numbers are meaningless for paint cost.
2. **DevTools Performance tab:** the raster bar is the painter; the UI bar is builds. Enable "Track widget rebuilds" to confirm that a frame rebuilds no widget (only repaints).
3. **Repaint rainbow / `debugRepaintRainbowEnabled`:** every bird should flash on its own; a flashing parent means a missing `RepaintBoundary` or a `setState` leak.
4. **Dart MCP `vm_service`** gives frame timings without leaving the editor; see [mcp-tooling-hub](../mcp-tooling-hub/SKILL.md).
5. **Measure the target crowd**, not one bird: the example page with two dozen birds is the baseline. Record the raster time before and after a painter change.

---

## 4. Performance Laws

1. **No allocation in `paint()`.** `Path`s cached per look, `Paint`s owned by the renderer, transforms via `canvas.save/translate/rotate/scale`.
2. **Repaint, don't rebuild.** `CustomPainter(repaint: seconds)`; `shouldRepaint` compares inputs by value (and the listenable by identity), never the time.
3. **One ticker per screen.** `PipitStage` is the only clock; it stops under `TickerMode(enabled: false)` and when `MediaQuery.disableAnimationsOf` is true.
4. **A `RepaintBoundary` per bird**, so a reaction on one bird rasterises one bird.
5. **No `saveLayer`.** Opacity and blending are done in the colour (`Color.withValues`), not with a layer; shadows are drawn shapes, not `MaskFilter` blur, unless measured to be cheap.
6. **Prove it.** A performance change ships with a before/after raster time from profile mode in the commit message or PR.

---

## 5. Verification Checklist

- [ ] Raster and UI times measured in profile mode on the example crowd, before and after.
- [ ] No widget rebuilds per frame ("Track widget rebuilds" is quiet while birds animate).
- [ ] `paint()` allocates nothing; no `saveLayer`, no `Opacity` widget, no blur.
- [ ] Each bird is inside its own `RepaintBoundary`.
- [ ] Hidden screens (`TickerMode`) and reduced motion stop the ticker.
