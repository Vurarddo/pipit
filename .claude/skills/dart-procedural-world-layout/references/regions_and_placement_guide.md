# Regions & Placement Guide

> **Parent Skill:** [dart-procedural-world-layout](../SKILL.md)

Where regions go, what shape they have, and where each item lives inside one.

---

## 1. Stable Seeds

```dart
/// FNV-1a over the UTF-16 code units: stable across runs and platforms,
/// unlike `String.hashCode`.
int stableHash(String key) {
  var h = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    h = ((h ^ unit) * 0x01000193) & 0xffffffff;
  }
  return h;
}

/// A generator private to one item and one purpose: the spot and the gait
/// of the same item never share a stream.
Random seeded(String id, String purpose, int worldSeed) =>
    Random(stableHash('$worldSeed/$purpose/$id'));
```

## 2. Slots

A slot is the space a region may use. Key it by the group, never by arrival order.

| World | Slot | Keyed by |
| :-- | :-- | :-- |
| Flat map, few fixed groups | A cell of a grid (e.g. 3 × 3 with the centre kept for a shared place) | The group's enum value → cell |
| Flat map, open-ended groups | A sector of a ring, angle from the group key's hash, radius by size | `stableHash(groupKey)` |
| Sphere | A cap: centre (lat, lon) and angular radius | Fixed table for known groups, hash for new ones |

Size a region by `sqrt(count)`, so area grows with the number of items.

## 3. Organic Outlines Fitted to a Slot

An outline is `n` radii around the slot centre with low-frequency wobble, smoothed through the
midpoints of neighbouring points (quadratic curves). Then it is scaled toward its centre until
every point is inside the slot minus a gap — the gap is what guarantees no two regions touch.

```dart
List<(double, double)> outline(double cx, double cy, double rx, double ry,
    Random rng, ({double x0, double y0, double x1, double y1}) box, {int n = 9}) {
  final k1 = 2 + rng.nextInt(2), k2 = 4 + rng.nextInt(2);
  final ph1 = rng.nextDouble() * 2 * pi, ph2 = rng.nextDouble() * 2 * pi;
  final pts = [
    for (var i = 0; i < n; i++)
      () {
        final a = 2 * pi * i / n;
        final r = 1 + 0.2 * sin(k1 * a + ph1) + 0.1 * sin(k2 * a + ph2);
        return (cx + cos(a) * rx * r, cy + sin(a) * ry * r);
      }(),
  ];
  var s = 1.0; // the largest scale that keeps every point inside the box
  for (final (x, y) in pts) {
    if (x < box.x0) s = min(s, (cx - box.x0) / (cx - x));
    if (x > box.x1) s = min(s, (box.x1 - cx) / (x - cx));
    if (y < box.y0) s = min(s, (cy - box.y0) / (cy - y));
    if (y > box.y1) s = min(s, (box.y1 - cy) / (y - cy));
  }
  return [for (final (x, y) in pts) (cx + (x - cx) * s, cy + (y - cy) * s)];
}
```

A soft edge is the painter's job (a radial gradient to transparent), not the layout's.

## 4. Placement Inside a Polygon

1. Shrink the outline toward its centre (e.g. to 80 %) so items do not stand on the edge.
2. For each item, draw candidates from `seeded(id, 'home', seed)` in the region's bounding box and
   keep the first inside the polygon (even–odd ray test). Cap the attempts; fall back to the centre.
3. Relax spacing within the region only: a few passes pushing pairs closer than the minimum
   distance apart, items in id order, pushed points clamped back inside. Other regions are untouched.

```dart
bool inside(double x, double y, List<(double, double)> poly) {
  var hit = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final (ax, ay) = poly[i], (bx, by) = poly[j];
    if ((ay > y) != (by > y) && x < ax + (y - ay) * (bx - ax) / (by - ay)) hit = !hit;
  }
  return hit;
}
```

## 5. Points on a Sphere, Caps as Continents

- **Lattice:** a Fibonacci sphere gives `N` evenly spread points without clumping at the poles:
  `y = 1 - 2(i + 0.5)/N`, `r = sqrt(1 - y²)`, `θ = i · π(3 - √5)`, point `(r cos θ, y, r sin θ)`.
- **Land:** a lattice point belongs to the cap whose centre is nearest by great-circle angle, if
  that angle is below the cap's radius times a wobble `1 + a·sin(k·bearing + φ)` — a ragged coast.
  Caps are placed far enough apart that radii never meet (the sphere's version of the slot gap).
- **Items:** rank a cap's land points by `stableHash('$id/$point')` and give each item the best
  free one, so an item keeps its point when others join.
- **Projection:** rotate by yaw (around y) and tilt (around x), draw orthographically
  `(cx + R·x, cy - R·y)`; points with `z < 0` are on the far side — skip them or dim them.
  The lattice and the land test run once per graph change (in an isolate if `N` is large); a turn
  is only the rotation, done per frame on the reused buffer.

## 6. Stability Rules, Tested

| Change | Allowed to move |
| :-- | :-- |
| Item added or removed | Items of its own region (spacing relaxation) |
| Region added | Nothing that exists: it takes a free slot |
| Seed changed | Everything (the seed is the world) |
