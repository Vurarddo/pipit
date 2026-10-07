import 'package:flutter/painting.dart';

/// Finds the bird under a point without asking every bird: indices bucketed
/// by the grid cells their bodies touch, in scene units. The bird drawn last
/// (on top) wins.
class DashHitGrid(final double _cell) {
  final Map<int, List<int>> _cells = {};
  final List<Offset> _centres = [];
  final List<double> _radii = [];

  static int _key(int x, int y) => (x & 0xFFFF) << 16 | (y & 0xFFFF);

  void rebuild(List<Offset> centres, List<double> radii) {
    _cells.clear();
    _centres
      ..clear()
      ..addAll(centres);
    _radii
      ..clear()
      ..addAll(radii);
    for (var i = 0; i < centres.length; i++) {
      final c = centres[i];
      final r = radii[i];
      for (var x = ((c.dx - r) / _cell).floor(); x <= ((c.dx + r) / _cell).floor(); x++) {
        for (var y = ((c.dy - r) / _cell).floor(); y <= ((c.dy + r) / _cell).floor(); y++) {
          (_cells[_key(x, y)] ??= []).add(i);
        }
      }
    }
  }

  int? hit(Offset point) {
    final bucket = _cells[_key((point.dx / _cell).floor(), (point.dy / _cell).floor())];
    if (bucket == null) return null;
    for (final i in bucket.reversed) {
      if ((point - _centres[i]).distance <= _radii[i]) return i;
    }
    return null;
  }
}
