import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_accessories.dart';
import 'package:pipit/src/pipit_accessory.dart';
import 'package:pipit/src/pipit_face.dart';
import 'package:pipit/src/pipit_facing.dart';
import 'package:pipit/src/pipit_feet.dart';
import 'package:pipit/src/pipit_geometry.dart';
import 'package:pipit/src/pipit_ink.dart';
import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';

typedef _G = PipitGeometry;

/// Left side view: one eye and the beak forward, one wing on the body.
class PipitSideView(final PipitInk _ink, final PipitAccessories _accessories) {
  this : _feet = PipitFeet(_ink), _face = PipitFace(_ink);

  final PipitFeet _feet;
  final PipitFace _face;
  final Path _wing = _G.sideWingPath();
  final Path _beak = _G.sideBeakPath();

  void paint(Canvas canvas, PipitLook look, PipitMotion motion, PipitAccessory accessory) {
    _feet.paint(canvas, look, motion, _G.sideLegs, profile: true);
    canvas.save();
    PipitInk.pose(canvas, motion);
    _ink.headFeathers(canvas, look, const [1]);
    _ink.tuft(canvas, look, shiftX: _G.sideTuftShift, lean: _G.sideTuftLean, raise: motion.tuft);
    _ink.fill(canvas, _ink.body, look.body);
    _ink.insideBody(canvas, _G.sideBelly, look.belly);
    // The iris sits forward (left) of centre: the bird looks where it faces.
    _face.eye(
      canvas,
      look,
      motion,
      _G.sideEye,
      0,
      eyeSize: _G.sideEyeSize,
      maskSize: _G.sideMask,
      gaze: const Offset(-0.025, 0),
    );
    canvas.save();
    canvas.translate(_G.sideWing.dx, _G.sideWing.dy);
    canvas.rotate(-motion.wing);
    _ink.fill(canvas, _wing, look.wing);
    canvas.restore();
    _ink.fill(canvas, _beak, look.beak);
    _accessories.paint(canvas, look, accessory, PipitFacing.left);
    canvas.restore();
  }
}
