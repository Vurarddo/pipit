import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:dash_bird/src/dash_terrain.dart';
import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_meadow_growth.dart';
import 'package:dash_bird/src/dash_meadow_shapes.dart';
import 'package:dash_bird/src/dash_meadow_terrain.dart';

/// Draws a meadow's ground under its flock, seen through [camera], faded
/// to [visibility] (while the birds leave it for their wires). Every
/// path and shader is built once per painter; a frame only moves the canvas.
class DashMeadowPainter({
  required final DashMeadowTerrain terrain,
  required final DashTerrain colors,
  required final ValueListenable<DashCamera> camera,
  final ValueListenable<double>? visibility,
}) extends CustomPainter {
  this : super(repaint: Listenable.merge([camera, visibility]));

  final Paint _fill = Paint();
  final Paint _layer = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final List<(Path, Shader)> _fields = [
    for (final f in terrain.fields)
      (
        DashMeadowShapes.smoothed(f.corners),
        ui.Gradient.radial(
          f.centre,
          f.reach,
          [
            f.color.withValues(alpha: colors.fieldPeak),
            f.color.withValues(alpha: colors.fieldPeak * 0.6),
            f.color.withValues(alpha: 0),
          ],
          const [0, 0.55, 1],
        ),
      ),
  ];

  late final Path _paths = () {
    final path = Path();
    for (final p in terrain.paths) {
      path.addPath(DashMeadowShapes.polyline(p), Offset.zero);
    }
    return path;
  }();

  late final Path _tufts = () {
    final path = Path();
    final t = terrain.tufts;
    for (var i = 0; i < t.length; i += 3) {
      final x = t[i], y = t[i + 1];
      path
        ..moveTo(x - 4, y)
        ..relativeLineTo(2, -7)
        ..moveTo(x, y)
        ..relativeLineTo(0, -9)
        ..moveTo(x + 4, y)
        ..relativeLineTo(-2, -7);
    }
    return path;
  }();

  late final Float32List _flowerPoints = Float32List.fromList([
    for (var i = 0; i < terrain.flowers.length; i += 3) ...[
      terrain.flowers[i],
      terrain.flowers[i + 1],
    ],
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    final shown = visibility?.value ?? 1;
    if (shown <= 0) return;
    if (shown < 1) {
      canvas.saveLayer(Offset.zero & size, _layer..color = colors.ground.withValues(alpha: shown));
    }
    _paintGround(canvas, size);
    if (shown < 1) canvas.restore();
  }

  void _paintGround(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _fill..color = colors.ground);
    final cam = camera.value;
    canvas
      ..save()
      ..scale(cam.zoom)
      ..translate(-cam.offset.dx, -cam.offset.dy);
    for (final (path, shader) in _fields) {
      canvas.drawPath(path, _fill..shader = shader);
    }
    _fill.shader = null;
    canvas.drawPath(
      _paths,
      _stroke
        ..color = colors.path
        ..strokeWidth = 14,
    );
    final pond = terrain.pond;
    canvas
      ..drawOval(pond.inflate(pond.width * 0.45), _fill..color = colors.clearing)
      ..drawOval(pond, _fill..color = colors.pond)
      ..drawOval(
        Rect.fromCenter(
          center: pond.center.translate(-pond.width * 0.12, -pond.height * 0.2),
          width: pond.width * 0.35,
          height: pond.height * 0.25,
        ),
        _fill..color = colors.pondHi.withValues(alpha: 0.6),
      )
      ..drawPath(
        _tufts,
        _stroke
          ..color = colors.grassHi
          ..strokeWidth = 1.4,
      )
      ..drawRawPoints(
        ui.PointMode.points,
        _flowerPoints,
        _stroke
          ..color = colors.flower
          ..strokeWidth = 3.6,
      );
    DashMeadowGrowth.paint(canvas, terrain, colors, _fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DashMeadowPainter old) =>
      old.terrain != terrain ||
      old.colors != colors ||
      old.camera != camera ||
      old.visibility != visibility;
}
