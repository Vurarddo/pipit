---
name: performance-expensive-operations
description: "Eliminating expensive GPU and paint work: saveLayer cost, Opacity vs FadeTransition, clipping, RepaintBoundary, BackdropFilter. Use when the GPU thread is the bottleneck."
metadata:
  category: performance
---

# Eliminating Expensive Paint & GPU Operations (`saveLayer` & `Opacity`)

## 1. Overview & Architectural Role

Certain visual effects in Flutter force the rendering engine to allocate an **offscreen buffer**, render the subtree into that buffer, and composite it back into the frame.

This mechanism—known internally as **`saveLayer()`**—is one of the most expensive operations on mobile and desktop GPUs, frequently causing severe frame drops (Raster thread jank).

---

## 2. The `saveLayer()` Pipeline & Cost

```mermaid
graph TD
    A["Standard Render Flow"] -->|Direct Draw| B["Screen Framebuffer (Fast & Instant)"]
    
    C["Expensive Visual Effect<br/>(Opacity, ClipPath, ShaderMask)"] -->|Triggers saveLayer()| D["1. Allocate Offscreen GPU Texture"]
    D --> E["2. Render Subtree to Offscreen Texture"]
    E --> F["3. Apply Alpha / Blend / Shader Filter"]
    F --> G["4. Composite Texture to Framebuffer (Heavy GPU Context Switch)"]
```

---

## 3. The `Opacity` Widget Anti-Pattern in Animations

Official Flutter Documentation: [Performance Considerations for Opacity Animation](https://api.flutter.dev/flutter/widgets/Opacity-class.html#performance-considerations-for-opacity-animation).

The `Opacity` widget applies opacity to its entire subtree as a single alpha group, requiring `saveLayer()` on **every single frame**.

### Rules for Opacity:
1. **Never use `Opacity` widget inside animations or transitions.**
2. **For animating opacity:** Always use **`FadeTransition`** or **`AnimatedOpacity`**, which optimize rendering internally.
3. **For static semi-transparent text, backgrounds, or containers:** Apply the alpha directly to the `Color` object rather than wrapping the widget in `Opacity`.

```dart
// ❌ BAD: Forces saveLayer() offscreen compositing on every build/animation frame!
Opacity(
  opacity: 0.5,
  child: Container(
    color: Colors.blue,
    child: const Text('Title'),
  ),
);

// ✅ GOOD (Static): Applies alpha directly to the color with ZERO saveLayer overhead!
Container(
  color: Colors.blue.withValues(alpha: 0.5),
  child: Text(
    'Title',
    style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
  ),
);

// ✅ GOOD (Animated): Uses optimized RenderAnimatedOpacity / FadeTransition
FadeTransition(
  opacity: _fadeAnimation,
  child: const HeavyContentWidget(),
);
```

---

## 4. Clipping Optimizations: `BoxDecoration` vs `ClipRRect`

Official Flutter Documentation: [SaveLayer Guidelines](https://docs.flutter.dev/perf/best-practices#use-savelayer-thoughtfully).

Clipping widgets (`ClipRect`, `ClipRRect`, `ClipOval`, `ClipPath`) create hard edges by clipping pixels, and using `Clip.antiAliasWithSaveLayer` causes extreme performance penalties.

### Clipping Best Practices:
1. **Prefer `BoxDecoration.borderRadius` over `ClipRRect`:**
   ```dart
   // ❌ BAD: Creates an unnecessary clipping layer
   ClipRRect(
     borderRadius: BorderRadius.circular(16.0),
     child: Container(
       color: context.colorScheme.surface,
       child: const ContentWidget(),
     ),
   );

   // ✅ GOOD: Renders rounded corners natively without clipping!
   Container(
     decoration: BoxDecoration(
       color: context.colorScheme.surface,
       borderRadius: BorderRadius.circular(16.0),
     ),
     child: const ContentWidget(),
   );
   ```

2. **Clip only when content overflows rounded bounds (e.g. images):**
   When clipping an image, use `Clip.hardEdge` (default) or `Clip.antiAlias`. NEVER use `Clip.antiAliasWithSaveLayer` unless rendering severe custom vector intersections.

---

## 5. `RepaintBoundary` Placement Standards

`RepaintBoundary` creates a separate display list for a widget subtree. When that subtree repaints, the parent layer tree does not need to repaint, and vice-versa.

### When to USE `RepaintBoundary`:
- Complex custom painters (e.g., real-time charts, candlestick graphs, audio visualizers).
- Continuous looping animations (e.g., loading spinners, pulsing indicators, shimmering skeletons).
- Camera feeds or video player surfaces.

### When NOT to USE `RepaintBoundary`:
- On trivial, fast-painting widgets (e.g. simple buttons, static text tiles).
- Wrapping every single item in a list (creates excessive GPU texture memory overhead).

```dart
// ✅ GOOD: Isolates high-frequency animation from repainting the surrounding static screen
class const LiveTickerView({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StaticHeaderCard(),
        const RepaintBoundary(
          child: LivePulsingProgressIndicator(),
        ),
        const StaticFooterCard(),
      ],
    );
  }
}
```

---

## 6. `ShaderMask` & `BackdropFilter` Viewport Limits

`BackdropFilter` (frosted glass / blur) reads the pixels behind it and applies a GPU Gaussian blur.

### Rules for Frosted Glass Effects:
1. Keep the blurred area as **small as possible** (e.g. navigation bar, modal dialog).
2. Avoid full-screen `BackdropFilter` during active scroll operations.
3. Combine with `RepaintBoundary` to isolate the blur layer from underlying static backgrounds.

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Wrapping animated widgets in `Opacity` | **CRITICAL** | Replace with `FadeTransition` or `AnimatedOpacity`. |
| Using `Clip.antiAliasWithSaveLayer` | **CRITICAL** | Replace with `Clip.hardEdge` or `Clip.antiAlias`. |
| Wrapping containers in `ClipRRect` when `BoxDecoration` suffices | **HIGH** | Use `BoxDecoration(borderRadius: ...)`. |
| Using `Opacity` to fade static colors | **HIGH** | Use `color.withValues(alpha: ...)`. |
| Overusing `RepaintBoundary` on simple static list items | **MEDIUM** | Remove redundant boundaries to prevent GPU texture bloat. |

---

## 8. Verification Checklist

- [ ] Zero `Opacity` widgets inside animations or transitions.
- [ ] Static transparency implemented via `Color.withValues(alpha:)`.
- [ ] No occurrences of `Clip.antiAliasWithSaveLayer`.
- [ ] Rounded corners implemented via `BoxDecoration` / `CardShape` wherever possible.
- [ ] `RepaintBoundary` applied to continuous animations and complex custom painters.
