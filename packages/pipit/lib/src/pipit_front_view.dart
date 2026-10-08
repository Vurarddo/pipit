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

/// Front view: both eyes, the beak between them, wings at the sides.
class PipitFrontView(final PipitInk _ink, final PipitAccessories _accessories) {
  this : _feet = PipitFeet(_ink), _face = PipitFace(_ink);

  final PipitFeet _feet;
  final PipitFace _face;
  final Path _wing = _G.wingPath();
  final Path _beak = _G.frontBeakPath();

  void paint(Canvas canvas, PipitLook look, PipitMotion motion, PipitAccessory accessory) {
    _feet.paint(canvas, look, motion, const [-_G.footSpread, _G.footSpread]);
    canvas.save();
    PipitInk.pose(canvas, motion);
    _ink.headFeathers(canvas, look, const [-1, 1]);
    _ink.tuft(canvas, look, raise: motion.tuft);
    _ink.fill(canvas, _ink.body, look.body);
    _ink.insideBody(canvas, _G.belly, look.belly);
    for (final side in const [-1.0, 1.0]) {
      _paintWing(canvas, look, side, motion.wing);
      _face.eye(canvas, look, motion, _G.eye.scale(side, 1), side);
    }
    _ink.fill(canvas, _beak, look.beak);
    _accessories.paint(canvas, look, accessory, PipitFacing.front);
    canvas.restore();
  }

  void _paintWing(Canvas canvas, PipitLook look, double side, double lift) {
    canvas.save();
    canvas.translate(side * _G.wingShoulder.dx, _G.wingShoulder.dy);
    canvas.scale(side, 1);
    canvas.rotate(_G.wingRestAngle - lift);
    _ink.fill(canvas, _wing, look.wing);
    canvas.restore();
  }
}
