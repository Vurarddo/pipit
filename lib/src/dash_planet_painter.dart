import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:dash_bird/src/dash_terrain.dart';
import 'package:dash_bird/src/dash_planet.dart';
import 'package:dash_bird/src/dash_planet_controller.dart';

/// Draws a dotted planet turned by [turn] (16.1 canvas): land dots in their
/// continent's colour, brighter toward the viewer, the far side hidden; bird
/// dots bright with a halo, leads ringed in [gold], working birds in the
/// terrain's working colour. Dots are batched per colour and depth into
/// buffers built once, so a frame only rotates and fills them.
class DashPlanetPainter({
  required final DashPlanet planet,
  required final DashTerrain colors,
  required final Color gold,
  required final Color belly,
  required final ValueListenable<DashPlanetTurn> turn,
  final ValueListenable<bool>? birdsHidden,
}) extends CustomPainter {
  this : super(repaint: Listenable.merge([turn, birdsHidden]));

  /// Share of the shorter side the globe's diameter takes.
  static const double globeShare = 0.88;

  final Paint _fill = Paint();
  final Paint _dots = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  late final int _groups = planet.landColors.length;
  late final List<Float32List> _near = _buffers();
  late final List<Float32List> _far = _buffers();
  late final Int32List _nearCount = Int32List(_groups);
  late final Int32List _farCount = Int32List(_groups);
  late final Float32List _screen = Float32List(planet.points * 3);

  List<Float32List> _buffers() => [
    for (var g = 0; g < _groups; g++) Float32List(planet.land.where((l) => l == g).length * 2),
  ];

  /// A bird dot's radius on a globe of radius [r].
  static double birdRadius(double r) => max(2.4, r / 45) * 0.7;

  /// Where each bird on the near side is drawn in a canvas of [size]: its
  /// centre and dot radius, by id. Birds on the far side are left out.
  static Map<String, (Offset, double)> birdSpots(
    DashPlanet planet,
    DashPlanetTurn turn,
    Size size,
  ) {
    final (c, r) = frame(size);
    final screen = Float32List(planet.points * 3);
    project(planet, turn, c, r, screen);
    return {
      for (var b = 0; b < planet.birdPoints.length; b++)
        if (screen[3 * planet.birdPoints[b] + 2] > 0.05)
          planet.birdIds[b]: (
            Offset(screen[3 * planet.birdPoints[b]], screen[3 * planet.birdPoints[b] + 1]),
            birdRadius(r),
          ),
    };
  }

  /// The globe's centre and radius in a canvas of [size].
  static (Offset, double) frame(Size size) =>
      (size.center(Offset.zero), size.shortestSide * globeShare / 2);

  @override
  void paint(Canvas canvas, Size size) {
    final (c, r) = frame(size);
    final a = colors.atmosphere;
    canvas
      ..drawCircle(c, r * 1.05, _fill..color = a.withValues(alpha: 0.10))
      ..drawCircle(c, r, _fill..color = a.withValues(alpha: 0.12))
      ..drawCircle(
        c.translate(-r * 0.25, -r * 0.3),
        r * 0.62,
        _fill..color = a.withValues(alpha: 0.06),
      );
    project(planet, turn.value, c, r, _screen);
    _nearCount.fillRange(0, _groups, 0);
    _farCount.fillRange(0, _groups, 0);
    for (var i = 0; i < planet.points; i++) {
      final g = planet.land[i], z = _screen[3 * i + 2];
      if (g < 0 || z <= 0.02) continue;
      final (buf, counts) = z > 0.45 ? (_near, _nearCount) : (_far, _farCount);
      buf[g][2 * counts[g]] = _screen[3 * i];
      buf[g][2 * counts[g] + 1] = _screen[3 * i + 1];
      counts[g]++;
    }
    final dot = max(2.4, r / 45);
    for (var g = 0; g < _groups; g++) {
      final color = planet.landColors[g];
      _drawDots(canvas, _far[g], _farCount[g], color.withValues(alpha: 0.4), dot * 0.8);
      _drawDots(canvas, _near[g], _nearCount[g], color.withValues(alpha: 0.78), dot);
    }
    if (!(birdsHidden?.value ?? false)) _paintBirds(canvas, birdRadius(r));
    canvas.drawCircle(
      c,
      r,
      _dots
        ..color = a.withValues(alpha: colors.haze * 4)
        ..strokeWidth = 1.4,
    );
  }

  void _drawDots(Canvas canvas, Float32List buf, int count, Color color, double width) {
    if (count == 0) return;
    canvas.drawRawPoints(
      ui.PointMode.points,
      Float32List.sublistView(buf, 0, count * 2),
      _dots
        ..color = color
        ..strokeWidth = width,
    );
  }

  void _paintBirds(Canvas canvas, double r) {
    for (var b = 0; b < planet.birdPoints.length; b++) {
      final p = planet.birdPoints[b];
      if (_screen[3 * p + 2] <= 0.05) continue;
      final at = Offset(_screen[3 * p], _screen[3 * p + 1]);
      final color = planet.birdColors[b];
      canvas
        ..drawCircle(at, r * 1.8, _fill..color = color.withValues(alpha: 0.14))
        ..drawCircle(at, r, _fill..color = Color.lerp(color, belly, 0.35)!);
      final ring = switch (planet.birdMarks[b]) {
        DashPlanetMark.lead => gold,
        DashPlanetMark.working => colors.working,
        DashPlanetMark.none => null,
      };
      if (ring != null) {
        canvas.drawCircle(
          at,
          r + 1.5,
          _dots
            ..color = ring
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  /// Screen x, y and depth z of every lattice point, into [out].
  static void project(DashPlanet planet, DashPlanetTurn t, Offset c, double r, Float32List out) {
    final cy = cos(t.yaw), sy = sin(t.yaw), ct = cos(t.tilt), st = sin(t.tilt);
    final l = planet.lattice;
    for (var i = 0; i < planet.points; i++) {
      final x = l[3 * i], y = l[3 * i + 1], z = l[3 * i + 2];
      final x1 = x * cy + z * sy, z1 = -x * sy + z * cy;
      out[3 * i] = c.dx + r * x1;
      out[3 * i + 1] = c.dy - r * (y * ct - z1 * st);
      out[3 * i + 2] = y * st + z1 * ct;
    }
  }

  @override
  bool shouldRepaint(DashPlanetPainter old) =>
      old.planet != planet ||
      old.colors != colors ||
      old.turn != turn ||
      old.birdsHidden != birdsHidden;
}
