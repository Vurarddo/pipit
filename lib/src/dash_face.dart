import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';

typedef _G = DashGeometry;

/// One eye with its expression: open or shut, widened, looking somewhere,
/// squinting when happy, under a raised brow when worried. The front view
/// draws two, the side view one.
class DashFace(final DashInk _ink) {
  /// [side] is -1 for the bird's right eye (on the viewer's left), 1 for its
  /// left, 0 for the single eye of the side view; it mirrors the brow.
  /// [eyeSize] is the white of the eye; the front view's is round.
  void eye(
    Canvas canvas,
    DashLook look,
    DashMotion motion,
    Offset center,
    double side, {
    Size eyeSize = const Size(_G.eyeRadius * 2, _G.eyeRadius * 2),
    Size maskSize = const Size(_G.maskRadius * 2, _G.maskRadius * 2),
    Offset gaze = Offset.zero,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    _ink.oval(
      canvas,
      Rect.fromCenter(center: Offset.zero, width: maskSize.width, height: maskSize.height),
      look.mask,
      outlined: false,
    );
    canvas.save();
    canvas.scale(motion.eyeScale, motion.eyeScale * motion.eyeOpen);
    _ink.oval(
      canvas,
      Rect.fromCenter(center: Offset.zero, width: eyeSize.width, height: eyeSize.height),
      look.belly,
    );
    final iris = eyeSize.width / 2 * 0.73;
    final at = gaze + Offset(motion.look.dx, motion.look.dy) * _G.lookReach + const Offset(0, 0.01);
    _ink.dot(canvas, at, iris, look.iris);
    _ink.dot(canvas, at, iris * 0.68, look.pupil);
    _ink.dot(canvas, at + Offset(iris * 0.32, -iris * 0.4), iris * 0.25, look.belly);
    canvas.restore();
    if (motion.mood > 0) {
      final lid = _G.happyLid;
      final rise = lid.height * motion.mood;
      _ink.oval(
        canvas,
        Rect.fromLTRB(lid.left, lid.bottom - rise, lid.right, lid.bottom + rise),
        look.mask,
        outlined: false,
      );
    }
    if (motion.mood < 0) _brow(canvas, look, side, -motion.mood);
    canvas.restore();
  }

  void _brow(Canvas canvas, DashLook look, double side, double worry) {
    // Brows are drawn for the eye on the right; the other eye and the side
    // view (which looks left) mirror them.
    final mirror = side == 0 ? -1.0 : side;
    final inner = (_G.browInner - _G.eye).scale(mirror, 1).translate(0, -_G.browRaise * worry);
    final outer = (_G.browOuter - _G.eye).scale(mirror, 1);
    _ink.line(
      canvas,
      inner,
      Offset.lerp(inner, outer, worry.clamp(0.4, 1))!,
      look.outline,
      0.028,
      look,
    );
  }
}
