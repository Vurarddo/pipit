import 'dart:math' as math;

import 'package:dash_bird/src/dash_pose.dart';

/// Moves a bird from one pose to another along a critically damped spring,
/// computed from the stage's clock, so no bird owns an animation controller.
/// A change mid-way starts from wherever the bird is: nothing ever jumps.
class DashPoseTransition(DashPoseValues values) {
  this : _from = values, _to = values;

  DashPoseValues _from;
  DashPoseValues _to;
  double _start = 0;

  // Stiffness of the spring: settled to 1 % in about 0.5 s.
  static const double _omega = 13;

  DashPoseValues get target => _to;

  DashPoseValues at(double seconds) => DashPoseValues.lerp(_from, _to, progress(seconds - _start));

  void retarget(DashPoseValues to, double now) {
    _from = at(now);
    _to = to;
    _start = now;
  }

  /// 0 → 1 without overshoot: x(t) = 1 − (1 + ωt)·e^(−ωt).
  static double progress(double elapsed) {
    if (elapsed <= 0) return 0;
    final wt = _omega * elapsed;
    return 1 - (1 + wt) * math.exp(-wt);
  }
}
