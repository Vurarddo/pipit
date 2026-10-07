import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_pose.dart';

/// One bird of a flock, in scene units: [position] is the centre of its box
/// and [size] the box's side. Birds that share [spriteKey] share one sprite
/// when drawn small, so give birds of one look and accessory the same key.
class const DashFlockBird({
  required final String id,
  required final Offset position,
  required final double size,
  required final DashLook look,
  required final String spriteKey,
  final DashFacing facing = DashFacing.front,
  final DashAccessory accessory = DashAccessory.none,
  final DashPose pose = DashPose.standing,
});
