import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_expression.dart';
import 'package:pipit/src/pipit_motion.dart';

/// What the bird is doing. Where it is (in the air, on a wire) is the scene's
/// business; a pose only changes the bird's own body.
enum PipitPose { sitting, standing, walking, flying, sleeping, working, alert }

/// A pose and expression as plain numbers, so any two blend (`lerp`) and a
/// change of pose is a spring between them rather than a cut.
class const PipitPoseValues({
  final double crouch = 0,
  final double tilt = 0,
  final double spread = 0,
  final double flap = 0,
  final double step = 0,
  final double lid = 0,
  final double eyeScale = 1,
  final double tuft = 0,
  final double lookX = 0,
  final double lookY = 0,
  final double mood = 0,
}) {
  // Wing beat and walk rates (radians per second) and their reach.
  static const double _flapRate = 22;
  static const double _flapReach = 0.55;
  static const double _spreadAngle = 1.1;
  static const double _walkRate = 7;
  static const double _walkBob = 0.035;
  static const double _walkStep = 0.05;
  static const double _walkSway = 0.05;
  static const double _hover = 0.02;
  // The whole bird leans a little toward where it looks.
  static const double _leanToLook = 0.05;

  factory PipitPoseValues.of(PipitPose pose, [PipitExpression expression = PipitExpression.calm]) {
    final base = switch (pose) {
      PipitPose.standing => const PipitPoseValues(),
      PipitPose.sitting => const PipitPoseValues(crouch: 1),
      PipitPose.walking => const PipitPoseValues(step: 1),
      PipitPose.flying => const PipitPoseValues(crouch: 1, spread: 0.9, flap: 1),
      PipitPose.sleeping => const PipitPoseValues(crouch: 1, lid: 1, tilt: 0.1),
      PipitPose.working => const PipitPoseValues(
        tilt: -0.06,
        flap: 0.2,
        lookY: 0.6,
        eyeScale: 0.95,
      ),
      PipitPose.alert => const PipitPoseValues(spread: 0.35, eyeScale: 1.18, tuft: 1),
    };
    return PipitPoseValues(
      crouch: base.crouch,
      tilt: base.tilt,
      spread: base.spread,
      flap: base.flap,
      step: base.step,
      lid: expression.eyes == PipitEyes.closed ? 1 : base.lid,
      eyeScale: base.eyeScale,
      tuft: base.tuft,
      lookX: (base.lookX + expression.look.dx).clamp(-1, 1),
      lookY: (base.lookY + expression.look.dy).clamp(-1, 1),
      mood: expression.mood.clamp(-1, 1),
    );
  }

  static PipitPoseValues lerp(PipitPoseValues a, PipitPoseValues b, double t) {
    double mix(double x, double y) => lerpDouble(x, y, t)!;
    return PipitPoseValues(
      crouch: mix(a.crouch, b.crouch),
      tilt: mix(a.tilt, b.tilt),
      spread: mix(a.spread, b.spread),
      flap: mix(a.flap, b.flap),
      step: mix(a.step, b.step),
      lid: mix(a.lid, b.lid),
      eyeScale: mix(a.eyeScale, b.eyeScale),
      tuft: mix(a.tuft, b.tuft),
      lookX: mix(a.lookX, b.lookX),
      lookY: mix(a.lookY, b.lookY),
      mood: mix(a.mood, b.mood),
    );
  }

  /// The motion to paint at [seconds]: these values over the bird's idle life.
  /// [blink] lets the idle blinks through; open or shut eyes hold still.
  PipitMotion over(PipitMotion idle, double seconds, double phase, {required bool blink}) {
    final walk = math.sin(seconds * _walkRate + phase);
    final beat = math.sin(seconds * _flapRate + phase);
    final eyes = (blink ? idle.eyeOpen : 1.0).clamp(0.0, 1.0);
    return PipitMotion(
      breath: idle.breath * (1 - flap * 0.7),
      eyeOpen: math.min(eyes, 1 - lid * 0.92),
      wing: idle.wing * (1 - flap) + spread * _spreadAngle + flap * _flapReach * beat,
      lift: step * _walkBob * walk.abs() + flap * _hover * (beat + 1) / 2,
      crouch: crouch,
      tilt: tilt + step * _walkSway * walk + lookX * _leanToLook,
      leftStep: step * _walkStep * math.max(0, walk),
      rightStep: step * _walkStep * math.max(0, -walk),
      eyeScale: eyeScale,
      look: Offset(lookX, lookY),
      mood: mood,
      tuft: tuft,
    );
  }
}
