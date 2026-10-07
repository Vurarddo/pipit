import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_gear_geometry.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';

typedef _A = DashGearGeometry;

/// What the bird carries: a whistle, an alarm clock, a messenger bag. The
/// back view mirrors the front, since the bird is seen from behind.
class DashGear(final DashInk _ink) {
  void whistle(Canvas canvas, DashLook look, DashFacing facing) {
    final at = facing == DashFacing.left ? _A.sideWhistle : _A.whistle;
    final cord = Path()
      ..moveTo(-_A.cordSpread, _A.cordTopY)
      ..quadraticBezierTo(at.dx, facing == DashFacing.back ? 0 : at.dy, _A.cordSpread, _A.cordTopY);
    _ink.trace(canvas, cord);
    if (facing == DashFacing.back) return;
    final body = RRect.fromRectXY(
      Rect.fromCenter(center: at, width: _A.whistleSize.width, height: _A.whistleSize.height),
      0.03,
      0.03,
    );
    _ink.fill(canvas, Path()..addRRect(body), look.metal);
  }

  void clock(Canvas canvas, DashLook look, DashFacing facing) {
    final at = switch (facing) {
      DashFacing.left => _A.sideClock,
      DashFacing.back => _A.clock.scale(-1, 1),
      _ => _A.clock,
    };
    for (final side in const [-1.0, 1.0]) {
      _ink.oval(
        canvas,
        Rect.fromCircle(
          center: at.translate(side * _A.clockRadius * 0.7, -_A.clockRadius * 0.9),
          radius: _A.bellRadius,
        ),
        look.gold,
      );
    }
    _ink.oval(canvas, Rect.fromCircle(center: at, radius: _A.clockRadius), look.gold);
    _ink.oval(canvas, Rect.fromCircle(center: at, radius: _A.clockRadius * 0.72), look.belly);
    _ink.line(canvas, at, at.translate(0, -_A.clockRadius * 0.5), look.pupil, 0.02, look);
    _ink.line(canvas, at, at.translate(_A.clockRadius * 0.4, 0), look.pupil, 0.02, look);
  }

  void bag(Canvas canvas, DashLook look, DashFacing facing) {
    final mirror = facing == DashFacing.back ? -1.0 : 1.0;
    final side = facing == DashFacing.left;
    final bag = side ? _A.sideBag : _mirrored(_A.bag, mirror);
    final from = side ? _A.sideStrapFrom : _A.strapFrom.scale(mirror, 1);
    _ink.line(canvas, from, bag.topCenter, look.leather, _A.strapWidth, look);
    _ink.fill(canvas, Path()..addRRect(RRect.fromRectXY(bag, 0.03, 0.03)), look.leather);
    final flap = Rect.fromLTRB(bag.left, bag.top, bag.right, bag.top + bag.height * 0.45);
    _ink.fill(canvas, Path()..addRRect(RRect.fromRectXY(flap, 0.03, 0.03)), look.leather);
  }

  static Rect _mirrored(Rect r, double mirror) =>
      mirror > 0 ? r : Rect.fromLTRB(-r.right, r.top, -r.left, r.bottom);
}
