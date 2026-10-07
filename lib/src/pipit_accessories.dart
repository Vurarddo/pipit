import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_accessory.dart';
import 'package:pipit/src/pipit_facing.dart';
import 'package:pipit/src/pipit_gear.dart';
import 'package:pipit/src/pipit_headwear.dart';
import 'package:pipit/src/pipit_ink.dart';
import 'package:pipit/src/pipit_look.dart';

/// Paints one accessory over a view; called inside the view's breathing
/// transform, so what the bird wears moves with it.
class PipitAccessories(PipitInk ink) {
  this : _head = PipitHeadwear(ink), _gear = PipitGear(ink);

  final PipitHeadwear _head;
  final PipitGear _gear;

  void paint(Canvas canvas, PipitLook look, PipitAccessory accessory, PipitFacing facing) {
    switch (accessory) {
      case PipitAccessory.none:
        return;
      case PipitAccessory.cap:
        _head.cap(canvas, look, facing);
      case PipitAccessory.crown:
        _head.crown(canvas, look, facing);
      case PipitAccessory.headband:
        _head.headband(canvas, look, facing);
      case PipitAccessory.helmet:
        _head.helmet(canvas, look, facing);
      case PipitAccessory.whistle:
        _gear.whistle(canvas, look, facing);
      case PipitAccessory.clock:
        _gear.clock(canvas, look, facing);
      case PipitAccessory.bag:
        _gear.bag(canvas, look, facing);
    }
  }
}
