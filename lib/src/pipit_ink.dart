import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_geometry.dart';
import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';

/// The pens every view draws with: one fill and one outline `Paint`, and the
/// parts all views share (feet, head feathers, tuft), so a frame allocates
/// nothing and the views cannot drift apart.
class PipitInk {
  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = PipitGeometry.outline
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  final Path body = PipitGeometry.bodyPath();

  void begin(PipitLook look) => _stroke.color = look.outline;

  void fill(Canvas canvas, Path path, Color color) {
    _fill.color = color;
    canvas.drawPath(path, _fill);
    canvas.drawPath(path, _stroke);
  }

  void oval(Canvas canvas, Rect rect, Color color, {bool outlined = true}) {
    _fill.color = color;
    canvas.drawOval(rect, _fill);
    if (outlined) canvas.drawOval(rect, _stroke);
  }

  void dot(Canvas canvas, Offset center, double radius, Color color) {
    _fill.color = color;
    canvas.drawCircle(center, radius, _fill);
  }

  /// Paints [area] clipped to the body, then the body's outline again on top;
  /// an oval unless [rect] asks for a straight band.
  void insideBody(Canvas canvas, Rect area, Color color, {bool rect = false}) {
    canvas.save();
    canvas.clipPath(body);
    _fill.color = color;
    rect ? canvas.drawRect(area, _fill) : canvas.drawOval(area, _fill);
    canvas.restore();
    canvas.drawPath(body, _stroke);
  }

  /// A stroke in [color] and [width], then the pen back to the outline.
  void line(Canvas canvas, Offset a, Offset b, Color color, double width, PipitLook look) {
    _stroke
      ..strokeWidth = width
      ..color = color;
    canvas.drawLine(a, b, _stroke);
    _stroke
      ..strokeWidth = PipitGeometry.outline
      ..color = look.outline;
  }

  /// An unfilled circle drawn with the outline pen, for rims.
  void ring(Canvas canvas, Offset center, double radius) =>
      canvas.drawCircle(center, radius, _stroke);

  /// An outline-only path, for cords and straps drawn as curves.
  void trace(Canvas canvas, Path path) => canvas.drawPath(path, _stroke);

  /// The two round feathers at the sides of the head; [sides] picks which.
  void headFeathers(Canvas canvas, PipitLook look, List<double> sides) {
    for (final side in sides) {
      oval(
        canvas,
        Rect.fromCircle(
          center: PipitGeometry.headFeather.scale(side, 1),
          radius: PipitGeometry.headFeatherRadius,
        ),
        look.wing,
      );
    }
  }

  /// The tuft; [lean] tilts all three feathers (the side view leans back),
  /// [raise] lifts them (0..1) when the bird is alert.
  void tuft(
    Canvas canvas,
    PipitLook look, {
    double shiftX = 0,
    double lean = 0,
    double raise = 0,
  }) {
    for (final (center, angle) in PipitGeometry.tuft) {
      canvas.save();
      canvas.translate(center.dx + shiftX, center.dy - raise * PipitGeometry.tuftRaise);
      canvas.rotate(angle + lean);
      oval(
        canvas,
        Rect.fromCenter(
          center: Offset.zero,
          width: PipitGeometry.tuftFeather.width,
          height: PipitGeometry.tuftFeather.height,
        ),
        look.wing,
      );
      canvas.restore();
    }
  }

  /// The body's place for this frame: lowered by a crouch, lifted, tilted
  /// around its centre, then breathing, a slight vertical stretch that keeps
  /// the feet on the ground.
  static void pose(Canvas canvas, PipitMotion motion) {
    // A squash flattens the bird onto its feet, not around its centre, and
    // widens it by half as much, which keeps the beak inside the bounds.
    canvas.translate(0, PipitGeometry.groundY);
    canvas.scale(1 + motion.squash / 2, 1 - motion.squash);
    canvas.translate(0, -PipitGeometry.groundY);
    canvas.translate(0, motion.crouch * PipitGeometry.crouchDrop - motion.lift);
    canvas.rotate(motion.tilt);
    canvas.translate(0, -0.008 * motion.breath);
    canvas.scale(1 - 0.01 * motion.breath, 1 + 0.016 * motion.breath);
  }
}
