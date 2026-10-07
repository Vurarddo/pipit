import 'dart:typed_data';

import 'package:flutter/rendering.dart';

/// The meadow's curves, built once per painter.
abstract final class DashMeadowShapes {
  /// Quadratic curves through the midpoints of neighbouring corners: the
  /// curve stays inside the corners' hull, so a field never leaves its cell.
  static Path smoothed(Float64List c) {
    final n = c.length ~/ 2;
    Offset mid(int i) => Offset(
      (c[2 * (i % n)] + c[2 * ((i + 1) % n)]) / 2,
      (c[2 * (i % n) + 1] + c[2 * ((i + 1) % n) + 1]) / 2,
    );
    final start = mid(n - 1);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = 0; i < n; i++) {
      final m = mid(i);
      path.quadraticBezierTo(c[2 * i], c[2 * i + 1], m.dx, m.dy);
    }
    return path..close();
  }

  static Path polyline(Float32List p) {
    final path = Path()..moveTo(p[0], p[1]);
    for (var i = 2; i < p.length - 2; i += 2) {
      path.quadraticBezierTo(
        p[i],
        p[i + 1],
        (p[i] + p[i + 2]) / 2,
        (p[i + 1] + p[i + 3]) / 2,
      );
    }
    return path..lineTo(p[p.length - 2], p[p.length - 1]);
  }
}
