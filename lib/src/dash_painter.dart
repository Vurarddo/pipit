import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_expression.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_pose.dart';
import 'package:dash_bird/src/dash_pose_transition.dart';
import 'package:dash_bird/src/dash_reactions.dart';
import 'package:dash_bird/src/dash_renderer.dart';

/// Paints one bird fitted to its box: its pose from [transition] at the
/// stage's time, over its idle life, repainted by [seconds] without a rebuild.
class DashPainter({
  required final DashLook look,
  required final DashIdle idle,
  required final DashPoseTransition transition,
  required final DashReactions reactions,
  final ValueListenable<double>? seconds,
  final DashFacing facing = DashFacing.front,
  final DashAccessory accessory = DashAccessory.none,
  final DashEyes eyes = DashEyes.blinking,
}) extends CustomPainter {
  this : _target = transition.target, super(repaint: seconds);

  final DashRenderer _renderer = DashRenderer();

  // The transition is one object for the bird's life; a new target is a new
  // object, which is how a bird without a clock still repaints its new pose.
  final DashPoseValues _target;

  @override
  void paint(Canvas canvas, Size size) {
    const bounds = DashRenderer.bounds;
    final unit = (size.width / bounds.width).clamp(0.0, size.height / bounds.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(unit);
    canvas.translate(-bounds.center.dx, -bounds.center.dy);
    final time = seconds?.value;
    final motion = time == null
        ? transition.target.over(DashMotion.rest, 0, 0, blink: false)
        : reactions.apply(
            transition
                .at(time)
                .over(idle.at(time), time, idle.phase, blink: eyes == DashEyes.blinking),
            time,
          );
    _renderer.paint(canvas, look, motion, facing: facing, accessory: accessory);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DashPainter old) =>
      old.look != look ||
      old.seconds != seconds ||
      old.facing != facing ||
      old.accessory != accessory ||
      old.eyes != eyes ||
      !identical(old._target, _target);
}
