import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_flock_bird.dart';
import 'package:dash_bird/src/dash_flock_focus.dart';
import 'package:dash_bird/src/dash_flock_motion.dart';
import 'package:dash_bird/src/dash_flock_view.dart';
import 'package:dash_bird/src/dash_meadow_painter.dart';
import 'package:dash_bird/src/dash_meadow_terrain.dart';
import 'package:dash_bird/src/dash_terrain.dart';

/// A flock on its meadow: the ground from [terrain] under
/// the birds, both seen through [camera]; [motion] lets the birds stroll.
/// [groundShown] fades the ground; [underFlock] lies between it and the
/// birds (their wires). [flockShown] false leaves the birds to a flight
/// drawn elsewhere.
class const DashMeadowView({
  super.key,
  required final DashMeadowTerrain terrain,
  required final List<DashFlockBird> birds,
  required final ValueListenable<double> seconds,
  required final ValueListenable<DashCamera> camera,
  required final String semanticLabel,
  final DashFlockMotion? motion,
  final ValueChanged<int>? onBirdTap,
  final ValueListenable<double>? groundShown,
  final Widget? underFlock,
  final bool flockShown = true,
  final ValueListenable<DashFlockFocus?>? focus,
  final void Function(int? index, Offset pointer)? onBirdHover,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: DashMeadowPainter(
              terrain: terrain,
              colors: DashTerrain.of(context),
              camera: camera,
              visibility: groundShown,
            ),
          ),
        ),
        ?underFlock,
        if (flockShown)
          DashFlockView(
            birds: birds,
            seconds: seconds,
            camera: camera,
            semanticLabel: semanticLabel,
            motion: motion,
            onBirdTap: onBirdTap,
            focus: focus,
            onBirdHover: onBirdHover,
          ),
      ],
    );
  }
}
