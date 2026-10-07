import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:dash_bird/src/dash_camera.dart';

/// The wires birds sit on: one line per row at [rows] (scene
/// y) from [left] to [right], seen through [camera], drawn at [shown]
/// opacity so they fade in while the birds fly onto them.
class DashWiresPainter({
  required final List<double> rows,
  required final double left,
  required final double right,
  required final Color color,
  required final ValueListenable<double> shown,
  required final ValueListenable<DashCamera> camera,
}) extends CustomPainter {
  this : super(repaint: Listenable.merge([shown, camera]));

  /// Birds stand on the wire: it runs this far below a row's seat line.
  static const double sag = 14;

  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = shown.value;
    if (opacity <= 0) return;
    final cam = camera.value;
    _line
      ..color = color.withValues(alpha: color.a * opacity)
      ..strokeWidth = 2 * cam.zoom.clamp(0.5, 2);
    for (final y in rows) {
      canvas.drawLine(
        cam.toScreen(Offset(left, y + sag)),
        cam.toScreen(Offset(right, y + sag)),
        _line,
      );
    }
  }

  @override
  bool shouldRepaint(DashWiresPainter old) =>
      old.rows != rows || old.color != color || old.shown != shown || old.camera != camera;
}
