# Motion & Morphing Guide

> **Parent Skill:** [dart-procedural-world-layout](../SKILL.md)

How placed items look alive, regroup and move between layouts — all as functions of time.

---

## 1. Wandering in Closed Form

Every item gets phases, frequencies and a home range from its own seed. Its offset from home at
time `t` is a sum of slow sines — smooth, bounded by the range, never synchronised with a neighbour.

```dart
final class Gait {
  Gait.of(String id, int worldSeed) {
    final r = seeded(id, 'gait', worldSeed);
    fx = 0.05 + r.nextDouble() * 0.07; // cycles per second: a slow stroll
    fy = 0.04 + r.nextDouble() * 0.06;
    px = r.nextDouble() * 2 * pi;
    py = r.nextDouble() * 2 * pi;
  }
  late final double fx, fy, px, py;

  /// Offset in units of the home range; |x|, |y| stay below 1.
  (double, double) offset(double t) => (
    0.7 * sin(2 * pi * fx * t + px) + 0.3 * sin(2 * pi * fx * 2.3 * t + py),
    0.7 * sin(2 * pi * fy * t + py) + 0.3 * sin(2 * pi * fy * 1.7 * t + px),
  );
}
```

- **Facing** follows the sign of the x velocity (the derivative of the same sines) — no state.
- **Walking vs standing:** the speed (length of the derivative) below a threshold means standing;
  the painter plays the step cycle only while walking.
- **Keep homes inside:** the range is at most the distance from home to the region's shrunk edge.

## 2. Hops, Flights and Dozing as Windows

Periodic windows derived from the seed decide what an item is doing, without a scheduler:

```dart
/// 0 outside a flight, rising and falling 0 → 1 → 0 inside one.
double lift(double t, double period, double phase, double length) {
  final local = (t + phase) % period;
  return local < length ? sin(pi * local / length) : 0;
}
```

A long period with a short length makes flights rare; a doze is the same window read as "eyes
closed". Items that are busy (a state from the domain, passed in) skip dozing.

## 3. Gathering Around a Chosen Item

`gather(chosen, linked, centre)` is another pure layout: the chosen item at the centre, the linked
ones on a ring around it in id order (angle `2π·i/n`, radius growing with `n`), every other item at
home. Showing it is a morph from the current layout to this one; releasing it is the morph back.
The others dim in the painter; the layout does not know about opacity.

## 4. Morphing Between Layouts

Both layouts are buffers in the same item order, so a morph is per item:

- **Stagger:** each item starts after `delay = hash01(id) · spread`, so a flock leaves as a flock,
  not as one block.
- **Arc:** interpolate along a quadratic curve whose control point is the midpoint lifted by a
  fraction of the distance — items fly, they do not slide.
- **Ease:** drive progress with a critically damped spring or `Curves.easeInOut` from the widget
  layer; the layout function takes `progress` in `[0, 1]` and stays pure.
- **Interruption:** reversing a morph means running the same function with progress going back;
  because nothing is stepped, a half-finished morph reverses without a jump.

Wandering keeps playing during a morph: the drawn position is `morph(home_a, home_b, p) + offset(t)`
scaled by `1 - p·(1 - p)·4` if the offset should calm down mid-flight.

## 5. Isolates

Run a pass in `Isolate.run` only when profile mode shows it costs a frame (a sphere lattice of many
thousands of points, relaxation of thousands of items). Send and return typed lists; the result
replaces the buffers on the UI isolate in one assignment. Per-frame work (rotation, motion) stays
on the UI isolate and allocates nothing.

## 6. Tests

| What | How |
| :-- | :-- |
| Determinism | Two runs, same seed → `expect(a, orderedEquals(b))` on the buffers |
| No overlap | Sample each outline's edge; no sample is inside another outline |
| Containment | Every home passes `inside` for its region |
| Stability | Add an item to region A; every item of B keeps identical coordinates |
| Motion bounds | For many `t`, `offset(t)` stays within the range; `t = 0` is the rest pose |
| Morph ends | `progress 0` equals layout A, `progress 1` equals layout B, exactly |
