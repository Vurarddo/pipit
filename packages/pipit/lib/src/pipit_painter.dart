import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:pipit/src/pipit_accessory.dart';
import 'package:pipit/src/pipit_expression.dart';
import 'package:pipit/src/pipit_facing.dart';
import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';
import 'package:pipit/src/pipit_pose.dart';
import 'package:pipit/src/pipit_pose_transition.dart';
import 'package:pipit/src/pipit_reactions.dart';
import 'package:pipit/src/pipit_renderer.dart';

/// Paints one bird fitted to its box: its pose from [transition] at the
/// stage's time, over its idle life, repainted by [seconds] without a rebuild.
class PipitPainter({
  required final PipitLook look,
  required final PipitIdle idle,
  required final PipitPoseTransition transition,
  required final PipitReactions reactions,
  final ValueListenable<double>? seconds,
  final PipitFacing facing = PipitFacing.front,
  final PipitAccessory accessory = PipitAccessory.none,
  final PipitEyes eyes = PipitEyes.blinking,
}) extends CustomPainter {
  this : _target = transition.target, super(repaint: seconds);

  final PipitRenderer _renderer = PipitRenderer();

  // The transition is one object for the bird's life; a new target is a new
  // object, which is how a bird without a clock still repaints its new pose.
  final PipitPoseValues _target;

  @override
  void paint(Canvas canvas, Size size) {
    const bounds = PipitRenderer.bounds;
    final unit = (size.width / bounds.width).clamp(0.0, size.height / bounds.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(unit);
    canvas.translate(-bounds.center.dx, -bounds.center.dy);
    final time = seconds?.value;
    final motion = time == null
        ? transition.target.over(PipitMotion.rest, 0, 0, blink: false)
        : reactions.apply(
            transition
                .at(time)
                .over(idle.at(time), time, idle.phase, blink: eyes == PipitEyes.blinking),
            time,
          );
    _renderer.paint(canvas, look, motion, facing: facing, accessory: accessory);
    canvas.restore();
  }

  @override
  bool shouldRepaint(PipitPainter old) =>
      old.look != look ||
      old.seconds != seconds ||
      old.facing != facing ||
      old.accessory != accessory ||
      old.eyes != eyes ||
      !identical(old._target, _target);
}
