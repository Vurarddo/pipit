import 'package:flutter/painting.dart';

/// Where each accessory sits, in the body units of `PipitGeometry`. Side view
/// numbers are for a bird looking left; the back view mirrors the front.
abstract final class PipitGearGeometry {
  // Crown: a band with three points, in front of the tuft's base.
  static const double crownBaseY = -0.42;
  static const double crownTopY = -0.72;
  static const double crownHalfWidth = 0.21;

  // Cap: a mortarboard over the tuft, its band and a tassel.
  static const Offset capCenter = Offset(0, -0.6);
  static const Size capBoard = Size(0.64, 0.2);
  static const Size capBand = Size(0.3, 0.1);
  static const double tasselDrop = 0.2;

  static const double glassesRadius = 0.135;
  static const Offset sideGlassesArm = Offset(0.1, -0.14);

  // Helmet: a dome over the head with a brim.
  static const Rect helmetDome = Rect.fromLTRB(-0.36, -0.68, 0.36, -0.08);
  static const Rect helmetBrim = Rect.fromLTRB(-0.42, -0.4, 0.42, -0.35);

  // Headband across the forehead, knotted at the side.
  static const Rect band = Rect.fromLTRB(-0.5, -0.31, 0.5, -0.22);
  static const Offset bandKnot = Offset(0.47, -0.26);
  static const Size bandTail = Size(0.08, 0.16);

  // Whistle on a cord around the neck.
  static const Offset whistle = Offset(0, 0.3);
  static const Offset sideWhistle = Offset(-0.34, 0.26);
  static const Size whistleSize = Size(0.13, 0.08);
  static const double cordSpread = 0.3;
  static const double cordTopY = -0.12;

  // Alarm clock held at the side.
  static const Offset clock = Offset(0.53, 0.3);
  static const Offset sideClock = Offset(0.4, 0.34);
  static const double clockRadius = 0.14;
  static const double bellRadius = 0.045;

  // Messenger bag at the hip on a strap from the other shoulder.
  static const Rect bag = Rect.fromLTRB(0.2, 0.2, 0.46, 0.42);
  static const Rect sideBag = Rect.fromLTRB(0.1, 0.2, 0.36, 0.42);
  static const Offset strapFrom = Offset(-0.32, -0.36);
  static const Offset sideStrapFrom = Offset(0.04, -0.42);
  static const double strapWidth = 0.035;

  /// Headwear in the side view sits a little back, over the leaning tuft.
  static const double sideHeadShift = 0.05;
}
