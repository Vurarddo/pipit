import 'dart:math' as math;

import 'package:dash_bird/src/dash_motion.dart';

/// Short reactions laid over a bird's motion: a hop with a flutter when the
/// pointer arrives, a squash when it is tapped. Each is a start time on the
/// stage's clock, so painting stays a pure function of the time.
class DashReactions {
  double? _hopAt;
  double? _squashAt;

  // A hop rises 0.05 body units and flutters for 0.35 s; a squash dips 12 %.
  static const double _hopTime = 0.35;
  static const double _hopHeight = 0.05;
  static const double _hopFlutter = 0.5;
  static const double _squashTime = 0.3;
  static const double _squashDepth = 0.12;

  void hop(double now) => _hopAt = now;

  void squash(double now) => _squashAt = now;

  DashMotion apply(DashMotion m, double seconds) {
    final hop = _progress(_hopAt, seconds, _hopTime);
    final squash = _progress(_squashAt, seconds, _squashTime);
    if (hop == null && squash == null) return m;
    final rise = hop == null ? 0.0 : math.sin(math.pi * hop);
    final flutter = hop == null ? 0.0 : (math.sin(hop * math.pi * 6)).abs() * (1 - hop);
    final dip = squash == null ? 0.0 : math.sin(math.pi * squash) * (1 - squash);
    return DashMotion(
      breath: m.breath,
      eyeOpen: m.eyeOpen,
      wing: m.wing + _hopFlutter * flutter,
      lift: m.lift + _hopHeight * rise,
      crouch: m.crouch,
      tilt: m.tilt,
      leftStep: m.leftStep,
      rightStep: m.rightStep,
      eyeScale: m.eyeScale,
      look: m.look,
      mood: m.mood,
      tuft: m.tuft,
      squash: m.squash + _squashDepth * dip,
    );
  }

  /// 0..1 through a reaction started at [start], or `null` outside it.
  static double? _progress(double? start, double now, double length) {
    if (start == null) return null;
    final k = (now - start) / length;
    return k < 0 || k >= 1 ? null : k;
  }
}
