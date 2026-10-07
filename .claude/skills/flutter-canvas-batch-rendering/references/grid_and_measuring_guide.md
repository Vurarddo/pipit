# Spatial Grid, Culling and Measuring

---

## 1. A Grid for Hit Tests

Bucket each object's index by the grid cells its bounds touch. A query looks at one cell and
checks the few objects there, last drawn first, so the one on top wins.

```dart
class HitGrid(final double cell) {
  final Map<int, List<int>> _cells = {};
  final List<Rect> _bounds = [];

  static int _key(int x, int y) => (x & 0xFFFF) << 16 | (y & 0xFFFF);

  void rebuild(List<Rect> bounds) {
    _cells.clear();
    _bounds
      ..clear()
      ..addAll(bounds);
    for (final (i, b) in bounds.indexed) {
      for (var x = (b.left / cell).floor(); x <= (b.right / cell).floor(); x++) {
        for (var y = (b.top / cell).floor(); y <= (b.bottom / cell).floor(); y++) {
          (_cells[_key(x, y)] ??= []).add(i);
        }
      }
    }
  }

  /// The top-most object whose [hits] test passes at [point], or `null`.
  int? hit(Offset point, bool Function(int index, Offset point) hits) {
    final bucket = _cells[_key((point.dx / cell).floor(), (point.dy / cell).floor())];
    if (bucket == null) return null;
    for (final i in bucket.reversed) {
      if (_bounds[i].contains(point) && hits(i, point)) return i;
    }
    return null;
  }
}
```

Test in scene units: convert the pointer with the inverse of the camera transform first. For round
objects, `hits` checks the distance to the centre, so corners of the bounds do not count.

## 2. Culling

Compute the viewport in scene units once per frame (the inverse camera transform of the canvas
size) and skip any object whose bounds do not overlap it before choosing its level.

## 3. Measuring

- Run `flutter run --profile` and read `FrameTiming` (`SchedulerBinding.instance.addTimingsCallback`):
  build and raster durations, their average and 90th percentile, frames over 16.7 ms.
- Measure each level alone (all live, all sprites, all dots), then the mix, at the counts you plan.
- A throwaway benchmark entrypoint is fine for a spike; record the numbers where the team decides
  (the roadmap), then delete it.
