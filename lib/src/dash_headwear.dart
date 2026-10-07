import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_gear_geometry.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';

typedef _A = DashGearGeometry;

/// What the bird wears on its head: crown, cap with glasses, helmet, band.
/// [facing] is front, left (the side view) or back; right is left mirrored.
class DashHeadwear(final DashInk _ink) {
  late final Path _crown = Path()
    ..moveTo(-_A.crownHalfWidth, _A.crownBaseY)
    ..lineTo(-_A.crownHalfWidth, _A.crownTopY + 0.04)
    ..lineTo(-_A.crownHalfWidth / 2, _A.crownBaseY - 0.1)
    ..lineTo(0, _A.crownTopY)
    ..lineTo(_A.crownHalfWidth / 2, _A.crownBaseY - 0.1)
    ..lineTo(_A.crownHalfWidth, _A.crownTopY + 0.04)
    ..lineTo(_A.crownHalfWidth, _A.crownBaseY)
    ..close();

  late final Path _board = Path()
    ..moveTo(-_A.capBoard.width / 2, _A.capCenter.dy)
    ..lineTo(0, _A.capCenter.dy - _A.capBoard.height / 2)
    ..lineTo(_A.capBoard.width / 2, _A.capCenter.dy)
    ..lineTo(0, _A.capCenter.dy + _A.capBoard.height / 2)
    ..close();

  late final Path _dome = Path()
    ..addArc(_A.helmetDome, 3.14159, 3.14159)
    ..close();

  void crown(Canvas canvas, DashLook look, DashFacing facing) {
    canvas.save();
    canvas.translate(_headShift(facing), 0);
    _ink.fill(canvas, _crown, look.gold);
    canvas.restore();
  }

  void cap(Canvas canvas, DashLook look, DashFacing facing) {
    if (facing != DashFacing.back) _glasses(canvas, look, facing);
    canvas.save();
    canvas.translate(_headShift(facing), 0);
    final band = Rect.fromCenter(
      center: _A.capCenter.translate(0, _A.capBand.height / 2),
      width: _A.capBand.width,
      height: _A.capBand.height,
    );
    _ink.fill(canvas, Path()..addRect(band), look.pupil);
    _ink.fill(canvas, _board, look.pupil);
    final tassel = Offset(_A.capBoard.width / 2 - 0.06, _A.capCenter.dy);
    _ink.line(canvas, tassel, tassel.translate(0.01, _A.tasselDrop), look.gold, 0.025, look);
    canvas.restore();
  }

  void helmet(Canvas canvas, DashLook look, DashFacing facing) {
    canvas.save();
    canvas.translate(_headShift(facing), 0);
    _ink.fill(canvas, _dome, look.metal);
    _ink.fill(canvas, Path()..addRRect(RRect.fromRectXY(_A.helmetBrim, 0.02, 0.02)), look.metal);
    canvas.restore();
  }

  void headband(Canvas canvas, DashLook look, DashFacing facing) {
    _ink.insideBody(canvas, _A.band, look.band, rect: true);
    final knot = switch (facing) {
      DashFacing.back => Offset(0, _A.bandKnot.dy),
      _ => _A.bandKnot,
    };
    for (final lean in const [-0.5, 0.4]) {
      canvas.save();
      canvas.translate(knot.dx, knot.dy);
      canvas.rotate(lean);
      _ink.oval(
        canvas,
        Rect.fromLTWH(-_A.bandTail.width / 2, 0, _A.bandTail.width, _A.bandTail.height),
        look.band,
      );
      canvas.restore();
    }
  }

  void _glasses(Canvas canvas, DashLook look, DashFacing facing) {
    if (facing == DashFacing.left) {
      _ink.ring(canvas, DashGeometry.sideEye, _A.glassesRadius);
      _ink.line(
        canvas,
        DashGeometry.sideEye.translate(_A.glassesRadius, 0),
        _A.sideGlassesArm,
        look.outline,
        DashGeometry.outline,
        look,
      );
      return;
    }
    for (final side in const [-1.0, 1.0]) {
      _ink.ring(canvas, DashGeometry.eye.scale(side, 1), _A.glassesRadius);
    }
  }

  double _headShift(DashFacing facing) => facing == DashFacing.left ? _A.sideHeadShift : 0;
}
