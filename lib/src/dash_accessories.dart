import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_gear.dart';
import 'package:dash_bird/src/dash_headwear.dart';
import 'package:dash_bird/src/dash_ink.dart';
import 'package:dash_bird/src/dash_look.dart';

/// Paints one accessory over a view; called inside the view's breathing
/// transform, so what the bird wears moves with it.
class DashAccessories(DashInk ink) {
  this : _head = DashHeadwear(ink), _gear = DashGear(ink);

  final DashHeadwear _head;
  final DashGear _gear;

  void paint(Canvas canvas, DashLook look, DashAccessory accessory, DashFacing facing) {
    switch (accessory) {
      case DashAccessory.none:
        return;
      case DashAccessory.cap:
        _head.cap(canvas, look, facing);
      case DashAccessory.crown:
        _head.crown(canvas, look, facing);
      case DashAccessory.headband:
        _head.headband(canvas, look, facing);
      case DashAccessory.helmet:
        _head.helmet(canvas, look, facing);
      case DashAccessory.whistle:
        _gear.whistle(canvas, look, facing);
      case DashAccessory.clock:
        _gear.clock(canvas, look, facing);
      case DashAccessory.bag:
        _gear.bag(canvas, look, facing);
    }
  }
}
