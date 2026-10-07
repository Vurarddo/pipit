import 'package:flutter/rendering.dart';

import 'package:dash_bird/src/dash_terrain.dart';
import 'package:dash_bird/src/dash_meadow_terrain.dart';

/// Bushes and trees of a meadow, drawn with the painter's own [Paint] (its
/// colour changes, nothing is allocated). Trees last, so they stand over
/// the grass and paths.
abstract final class DashMeadowGrowth {
  static void paint(Canvas canvas, DashMeadowTerrain terrain, DashTerrain colors, Paint fill) {
    _bushes(canvas, terrain, colors, fill);
    _trees(canvas, terrain, colors, fill);
  }

  static void _bushes(Canvas canvas, DashMeadowTerrain terrain, DashTerrain colors, Paint fill) {
    final b = terrain.bushes;
    for (var i = 0; i < b.length; i += 3) {
      final (x, y, s) = (b[i], b[i + 1], b[i + 2]);
      fill.color = colors.bush;
      canvas
        ..drawCircle(Offset(x - s * 0.4, y), s * 0.5, fill)
        ..drawCircle(Offset(x + s * 0.35, y + 1), s * 0.45, fill)
        ..drawCircle(Offset(x, y - s * 0.3), s * 0.55, fill..color = colors.grassHi);
    }
  }

  static void _trees(Canvas canvas, DashMeadowTerrain terrain, DashTerrain colors, Paint fill) {
    final t = terrain.trees;
    for (var i = 0; i < t.length; i += 3) {
      final (x, y, s) = (t[i], t[i + 1], t[i + 2]);
      canvas
        ..drawOval(
          Rect.fromCenter(center: Offset(x, y + 4), width: s * 1.8, height: s * 0.56),
          fill..color = colors.trunk.withValues(alpha: 0.35),
        )
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - s * 0.09, y - s * 0.9, s * 0.18, s * 0.9),
            const Radius.circular(2),
          ),
          fill..color = colors.trunk,
        )
        ..drawCircle(Offset(x - s * 0.35, y - s), s * 0.5, fill..color = colors.canopy)
        ..drawCircle(Offset(x + s * 0.35, y - s * 1.05), s * 0.48, fill)
        ..drawCircle(Offset(x, y - s * 1.35), s * 0.55, fill..color = colors.canopyHi);
    }
  }
}
