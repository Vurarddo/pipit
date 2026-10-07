import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Which way a planet is turned: [yaw] around its pole, [tilt] toward the
/// viewer, in radians.
typedef DashPlanetTurn = ({double yaw, double tilt});

/// Turns a planet by hand.
class DashPlanetController({final DashPlanetTurn initial = (yaw: 0.15, tilt: -0.18)})
    extends ValueNotifier<DashPlanetTurn> {
  this : super(initial);

  /// The pole never tips further than this toward or away from the viewer.
  static const double maxTilt = 1.1;

  /// Radians per pixel of drag, for a globe about 300 px across.
  static const double _dragRate = 0.008;

  void drag(Offset delta) {
    value = (
      yaw: value.yaw + delta.dx * _dragRate,
      // Dragging down brings the top of the planet toward the viewer.
      tilt: (value.tilt + delta.dy * _dragRate).clamp(-maxTilt, maxTilt),
    );
  }
}
