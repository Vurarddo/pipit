---
name: flutter-ui-advanced-graphics
description: "CustomPainter, Canvas, ShaderMask, SpringSimulation, Rive/Lottie. Use when building custom charts, procedural graphics, or physics-driven gestures."
metadata:
  category: presentation
---

# Flutter Advanced Graphics, CustomPainter & Physics Motion Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing custom charts, procedural backgrounds, wave shapes, or circular gauges via `CustomPainter`.
- Drawing directly to the 2D Skia/Impeller pipeline using `Canvas`, `Path`, and `Paint`.
- Applying custom GPU fragment shaders or `ShaderMask` gradient effects.
- Implementing gesture-driven physical springs (`SpringSimulation`, `FrictionSimulation`).
- Integrating dynamic vector runtime assets via Rive (`rive`) or Lottie animations.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation laws and UI routing. |
| **Basic Animations** | [flutter-ui-animations](../flutter-ui-animations/SKILL.md) | Standard animation controllers & curves. |
| **Performance** | [performance-rendering-build](../performance-rendering-build/SKILL.md) | Layer isolation using `RepaintBoundary`. |
| **Characters** | [flutter-procedural-character](../flutter-procedural-character/SKILL.md) | A mascot or avatar drawn and animated in code. |

---

## 3. High-Performance CustomPainter Architecture

1. **Always wrap in `RepaintBoundary`:** Prevents custom canvas draws from invalidating adjacent widget render layers.
2. **Implement `shouldRepaint` accurately:** Never return `true` blindly. Compare input fields to avoid repainting unchanged frames.
3. **Avoid object allocations inside `paint()`:** Allocate `Paint`, `Path`, and `TextStyle` objects outside or reuse fields.

---

## 4. Reference Implementation Guides (`references/`)

- **Custom Circular Gauge Painter Guide:** [references/circular_gauge_painter_guide.md](references/circular_gauge_painter_guide.md)
  - Custom canvas drawing with `drawCircle`, `drawArc`, and `RepaintBoundary` encapsulation.
- **Physics Spring Simulation Guide:** [references/physics_spring_draggable_guide.md](references/physics_spring_draggable_guide.md)
  - Natural gesture-driven spring motion using `SpringSimulation` and `AnimationController`.

---

## 5. Verification Checklist

- [ ] Canvas drawing wrapped inside `RepaintBoundary`.
- [ ] `shouldRepaint` accurately compares old and new delegate properties.
- [ ] Zero object allocations (`Paint()`, `Path()`) inside `paint()` loop.
- [ ] Gesture springs use `SpringSimulation` for natural velocity-based snapback.
