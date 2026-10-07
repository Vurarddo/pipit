import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_geometry.dart';
import 'package:pipit/src/pipit_ink.dart';
import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';

typedef _G = PipitGeometry;

/// Legs and toes. The toes stay on the ground unless a step lifts them; a
/// crouch lowers the body onto them, and the legs shorten under it.
class PipitFeet(final PipitInk _ink) {
  /// [legs] are x positions, left to right; in [profile] each foot is one long
  /// toe pointing forward (left), as the side view sees it.
  void paint(
    Canvas canvas,
    PipitLook look,
    PipitMotion motion,
    List<double> legs, {
    bool profile = false,
  }) {
    for (var i = 0; i < legs.length; i++) {
      final x = legs[i];
      final step = i == 0 ? motion.leftStep : motion.rightStep;
      final ground = _G.groundY - step;
      final top = _G.legTopY + motion.crouch * _G.crouchDrop - motion.lift;
      _ink.line(canvas, Offset(x, top), Offset(x, ground - 0.02), look.beak, _G.legWidth, look);
      if (profile) {
        _toe(canvas, look, Offset(x + _G.sideFootShift, ground), _G.sideFoot);
        continue;
      }
      for (final gap in const [-1, 0, 1]) {
        _toe(canvas, look, Offset(x + gap * _G.toeGap, ground), _G.toe);
      }
    }
  }

  void _toe(Canvas canvas, PipitLook look, Offset center, Size size) => _ink.oval(
    canvas,
    Rect.fromCenter(center: center, width: size.width, height: size.height),
    look.beak,
  );
}
