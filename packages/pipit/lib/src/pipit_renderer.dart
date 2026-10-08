import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_accessories.dart';
import 'package:pipit/src/pipit_accessory.dart';
import 'package:pipit/src/pipit_back_view.dart';
import 'package:pipit/src/pipit_facing.dart';
import 'package:pipit/src/pipit_front_view.dart';
import 'package:pipit/src/pipit_geometry.dart';
import 'package:pipit/src/pipit_ink.dart';
import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';
import 'package:pipit/src/pipit_side_view.dart';

/// Paints one bird in body units ([PipitGeometry]); the caller translates and
/// scales the canvas. One renderer paints any number of birds and allocates
/// nothing per frame: its paths and paints are built once.
class PipitRenderer() {
  this : _ink = PipitInk() {
    final accessories = PipitAccessories(_ink);
    _front = PipitFrontView(_ink, accessories);
    _side = PipitSideView(_ink, accessories);
    _back = PipitBackView(_ink, accessories);
  }

  /// Everything any view draws lies inside this rectangle.
  static const Rect bounds = PipitGeometry.bounds;

  final PipitInk _ink;
  late final PipitFrontView _front;
  late final PipitSideView _side;
  late final PipitBackView _back;

  void paint(
    Canvas canvas,
    PipitLook look,
    PipitMotion motion, {
    PipitFacing facing = PipitFacing.front,
    PipitAccessory accessory = PipitAccessory.none,
  }) {
    _ink.begin(look);
    switch (facing) {
      case PipitFacing.front:
        _front.paint(canvas, look, motion, accessory);
      case PipitFacing.left:
        _side.paint(canvas, look, motion, accessory);
      case PipitFacing.right:
        canvas.save();
        canvas.scale(-1, 1);
        _side.paint(canvas, look, motion, accessory);
        canvas.restore();
      case PipitFacing.back:
        _back.paint(canvas, look, motion, accessory);
    }
  }
}
