import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_accessories.dart';
import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_back_view.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_front_view.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_side_view.dart';

/// Paints one bird in body units ([DashGeometry]); the caller translates and
/// scales the canvas. One renderer paints any number of birds and allocates
/// nothing per frame: its paths and paints are built once.
class DashRenderer() {
  this : _ink = DashInk() {
    final accessories = DashAccessories(_ink);
    _front = DashFrontView(_ink, accessories);
    _side = DashSideView(_ink, accessories);
    _back = DashBackView(_ink, accessories);
  }

  /// Everything any view draws lies inside this rectangle.
  static const Rect bounds = DashGeometry.bounds;

  final DashInk _ink;
  late final DashFrontView _front;
  late final DashSideView _side;
  late final DashBackView _back;

  void paint(
    Canvas canvas,
    DashLook look,
    DashMotion motion, {
    DashFacing facing = DashFacing.front,
    DashAccessory accessory = DashAccessory.none,
  }) {
    _ink.begin(look);
    switch (facing) {
      case DashFacing.front:
        _front.paint(canvas, look, motion, accessory);
      case DashFacing.left:
        _side.paint(canvas, look, motion, accessory);
      case DashFacing.right:
        canvas.save();
        canvas.scale(-1, 1);
        _side.paint(canvas, look, motion, accessory);
        canvas.restore();
      case DashFacing.back:
        _back.paint(canvas, look, motion, accessory);
    }
  }
}
