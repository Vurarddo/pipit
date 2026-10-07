import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_accessories.dart';
import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_face.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_feet.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';

typedef _G = DashGeometry;

/// Left side view: one eye and the beak forward, one wing on the body.
class DashSideView(final DashInk _ink, final DashAccessories _accessories) {
  this : _feet = DashFeet(_ink), _face = DashFace(_ink);

  final DashFeet _feet;
  final DashFace _face;
  final Path _wing = _G.sideWingPath();
  final Path _beak = _G.sideBeakPath();

  void paint(Canvas canvas, DashLook look, DashMotion motion, DashAccessory accessory) {
    _feet.paint(canvas, look, motion, _G.sideLegs, profile: true);
    canvas.save();
    DashInk.pose(canvas, motion);
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
    _accessories.paint(canvas, look, accessory, DashFacing.left);
    canvas.restore();
  }
}
