import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_accessories.dart';
import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_feet.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';

typedef _G = DashGeometry;

/// Back view: no face; the tail over a pale rump, wings at the sides.
class DashBackView(final DashInk _ink, final DashAccessories _accessories) {
  this : _feet = DashFeet(_ink);

  final DashFeet _feet;
  final Path _wing = _G.wingPath();

  void paint(Canvas canvas, DashLook look, DashMotion motion, DashAccessory accessory) {
    _feet.paint(canvas, look, motion, const [-_G.footSpread, _G.footSpread]);
    canvas.save();
    DashInk.pose(canvas, motion);
    _ink.headFeathers(canvas, look, const [-1, 1]);
    _ink.tuft(canvas, look, raise: motion.tuft);
    _ink.fill(canvas, _ink.body, look.body);
    _ink.insideBody(canvas, _G.rump, look.belly);
    for (final (dx, angle) in _G.tailFeathers) {
      canvas.save();
      canvas.translate(_G.tail.dx + dx, _G.tail.dy);
      canvas.rotate(angle);
      _ink.oval(
        canvas,
        Rect.fromCenter(
          center: Offset.zero,
          width: _G.tailFeather.width,
          height: _G.tailFeather.height,
        ),
        look.wing,
      );
      canvas.restore();
    }
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(side * _G.wingShoulder.dx, _G.wingShoulder.dy);
      canvas.scale(side, 1);
      canvas.rotate(_G.wingRestAngle - motion.wing);
      _ink.fill(canvas, _wing, look.wing);
      canvas.restore();
    }
    _accessories.paint(canvas, look, accessory, DashFacing.back);
    canvas.restore();
  }
}
