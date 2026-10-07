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

/// Front view: both eyes, the beak between them, wings at the sides.
class DashFrontView(final DashInk _ink, final DashAccessories _accessories) {
  this : _feet = DashFeet(_ink), _face = DashFace(_ink);

  final DashFeet _feet;
  final DashFace _face;
  final Path _wing = _G.wingPath();
  final Path _beak = _G.frontBeakPath();

  void paint(Canvas canvas, DashLook look, DashMotion motion, DashAccessory accessory) {
    _feet.paint(canvas, look, motion, const [-_G.footSpread, _G.footSpread]);
    canvas.save();
    DashInk.pose(canvas, motion);
    _ink.headFeathers(canvas, look, const [-1, 1]);
    _ink.tuft(canvas, look, raise: motion.tuft);
    _ink.fill(canvas, _ink.body, look.body);
    _ink.insideBody(canvas, _G.belly, look.belly);
    for (final side in const [-1.0, 1.0]) {
      _paintWing(canvas, look, side, motion.wing);
      _face.eye(canvas, look, motion, _G.eye.scale(side, 1), side);
    }
    _ink.fill(canvas, _beak, look.beak);
    _accessories.paint(canvas, look, accessory, DashFacing.front);
    canvas.restore();
  }

  void _paintWing(Canvas canvas, DashLook look, double side, double lift) {
    canvas.save();
    canvas.translate(side * _G.wingShoulder.dx, _G.wingShoulder.dy);
    canvas.scale(side, 1);
    canvas.rotate(_G.wingRestAngle - lift);
    _ink.fill(canvas, _wing, look.wing);
    canvas.restore();
  }
}
