import 'package:flutter/painting.dart';

/// The bird's proportions in body units, taken from the multi-view sketch:
/// the body is a circle of diameter 1 around the origin, y grows downwards,
/// the side view looks to the left. Every view reads these numbers, so one
/// change reshapes the bird in all of them.
abstract final class DashGeometry {
  static const double bodyRadius = 0.5;
  static const double outline = 0.022;

  static const double groundY = 0.62;

  /// How far a crouch (sitting, sleeping, flying) lowers the body.
  static const double crouchDrop = 0.1;
  static const double legTopY = 0.4;
  static const double legWidth = 0.05;
  static const double footSpread = 0.14;
  static const Size toe = Size(0.075, 0.05);
  static const double toeGap = 0.055;

  static const Offset headFeather = Offset(0.33, -0.37);
  static const double headFeatherRadius = 0.1;

  /// Three tuft feathers: centre and lean (radians), left to right.
  static const List<(Offset, double)> tuft = [
    (Offset(-0.11, -0.55), -0.5),
    (Offset(0, -0.6), 0),
    (Offset(0.11, -0.55), 0.5),
  ];
  static const Size tuftFeather = Size(0.12, 0.2);

  static const Offset wingShoulder = Offset(0.44, 0.04);
  static const double wingRestAngle = -0.35;

  static const Offset eye = Offset(0.155, -0.06);
  static const double maskRadius = 0.17;
  static const double eyeRadius = 0.12;
  static const double irisRadius = 0.088;
  static const double pupilRadius = 0.06;

  // Expression: how far the pupils travel, the brows of a worried bird (inner
  // end first, per eye), the lower lid of a happy one.
  static const double lookReach = 0.03;
  static const Offset browInner = Offset(0.06, -0.26);
  static const Offset browOuter = Offset(0.22, -0.2);
  static const double browRaise = 0.05;
  static const Rect happyLid = Rect.fromLTRB(-0.17, 0.06, 0.17, 0.2);
  static const double tuftRaise = 0.04;

  static const Rect belly = Rect.fromLTRB(-0.37, 0.04, 0.37, 0.6);

  // Side view: the eye and beak move forward (left), one wing lies on the body.
  static const Offset sideEye = Offset(-0.25, -0.08);
  static const Size sideMask = Size(0.28, 0.34);
  static const Size sideEyeSize = Size(0.17, 0.22);
  static const Rect sideBelly = Rect.fromLTRB(-0.44, 0.02, 0.2, 0.58);
  static const Offset sideWing = Offset(0.06, 0.1);
  static const List<double> sideLegs = [0.1, -0.04];
  static const double sideTuftShift = 0.06;
  static const double sideTuftLean = 0.25;
  static const Size sideFoot = Size(0.16, 0.055);
  static const double sideFootShift = -0.04;

  // Back view: a tail of three short feathers over a pale rump.
  static const Rect rump = Rect.fromLTRB(-0.28, 0.32, 0.28, 0.58);
  static const Offset tail = Offset(0, 0.3);
  static const Size tailFeather = Size(0.1, 0.16);

  /// Three tail feathers: horizontal offset from [tail] and lean (radians).
  static const List<(double, double)> tailFeathers = [(-0.09, -0.5), (0.09, 0.5), (0, 0)];

  /// Everything any view draws lies inside this rectangle, so all views share
  /// one scale and stand side by side at the same size.
  static const Rect bounds = Rect.fromLTRB(-0.8, -0.8, 0.8, 0.7);

  /// The front wing: a teardrop hanging from the shoulder.
  static Path wingPath() => Path()
    ..moveTo(0, -0.1)
    ..cubicTo(0.15, -0.15, 0.22, 0.1, 0.13, 0.27)
    ..cubicTo(0.07, 0.34, -0.03, 0.2, 0, -0.1)
    ..close();

  /// The side wing: a longer teardrop lying along the body, tip to the back.
  static Path sideWingPath() => Path()
    ..moveTo(-0.14, -0.06)
    ..cubicTo(0.02, -0.16, 0.34, -0.06, 0.46, 0.16)
    ..cubicTo(0.26, 0.2, -0.06, 0.16, -0.14, -0.06)
    ..close();

  static Path frontBeakPath() => Path()
    ..moveTo(-0.075, 0.07)
    ..quadraticBezierTo(0, 0.045, 0.075, 0.07)
    ..quadraticBezierTo(0.02, 0.21, 0, 0.215)
    ..quadraticBezierTo(-0.02, 0.21, -0.075, 0.07)
    ..close();

  static Path sideBeakPath() => Path()
    ..moveTo(-0.45, -0.05)
    ..quadraticBezierTo(-0.62, -0.02, -0.73, 0.06)
    ..quadraticBezierTo(-0.6, 0.1, -0.45, 0.12)
    ..close();

  static Path bodyPath() =>
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: bodyRadius));
}
