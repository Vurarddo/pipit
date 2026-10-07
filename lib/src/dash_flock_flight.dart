import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dash_bird/src/stable_hash.dart';
import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_flock_bird.dart';
import 'package:dash_bird/src/dash_flock_motion.dart';
import 'package:dash_bird/src/dash_flock_view.dart';
import 'package:dash_bird/src/dash_pose.dart';
import 'package:dash_bird/src/dash_stage.dart';

/// Where a bird is at one end of a flight: its global centre and the side
/// of its box there.
typedef DashFlightSpot = (Offset centre, double size);

/// A flock flying between two screens: drawn in one
/// overlay over both routes, each bird from its spot in [from] to where
/// [birds] stand (global centre and box size), growing on the way. A bird
/// missing from [from] (unseen at the start) grows where it lands. Progress
/// is the route's [progress], so a pop flies them back.
class const DashFlockFlight({
  super.key,
  required final List<DashFlockBird> birds,
  required final Map<String, DashFlightSpot> from,
  required final Animation<double> progress,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DashStage(
        builder: (context, seconds) => DashFlockView(
          birds: birds,
          seconds: seconds,
          camera: _identity,
          semanticLabel: '',
          motion: _FlightMotion(birds, from, progress),
        ),
      ),
    );
  }

  static final ValueNotifier<DashCamera> _identity = ValueNotifier(const DashCamera());
}

class _FlightMotion(
  final List<DashFlockBird> _birds,
  final Map<String, DashFlightSpot> _from,
  final Animation<double> _progress,
) implements DashFlockScaling, DashFlockFacing, DashFlockPosing {
  /// Share of the flight over which the birds' departures are spread.
  static const double _spread = 0.3;

  /// An arc's rise, as a share of the distance flown.
  static const double _lift = 0.2;

  late final Float32List _delays = Float32List.fromList([
    for (final b in _birds) StableHash.unit(StableHash.seed('flight/${b.id}'), 0) * _spread,
  ]);

  double _local(int i) {
    final t = ((_progress.value - _delays[i]) / (1 - _spread)).clamp(0.0, 1.0);
    return Curves.easeInOutCubic.transform(t);
  }

  @override
  void offsets(double seconds, Float32List out) {
    for (var i = 0; i < _birds.length; i++) {
      final to = _birds[i].position;
      final (from, _) = _from[_birds[i].id] ?? (to, 0.0);
      final t = _local(i), u = 1 - t;
      final control = Offset.lerp(from, to, 0.5)! - Offset(0, _lift * (to - from).distance);
      final at = from * (u * u) + control * (2 * u * t) + to * (t * t);
      out[2 * i] = at.dx - to.dx;
      out[2 * i + 1] = at.dy - to.dy;
    }
  }

  @override
  void scales(double seconds, Float32List out) {
    for (var i = 0; i < _birds.length; i++) {
      final size = _birds[i].size;
      final (_, fromSize) = _from[_birds[i].id] ?? (Offset.zero, 0.0);
      out[i] = max(0, fromSize + (size - fromSize) * _local(i)) / size;
    }
  }

  /// On the way a bird is seen from the side it flies toward; landed or yet
  /// to leave, it faces us.
  @override
  void facings(double seconds, Uint8List out) {
    for (var i = 0; i < _birds.length; i++) {
      final to = _birds[i].position;
      final (from, _) = _from[_birds[i].id] ?? (to, 0.0);
      final t = _local(i);
      out[i] =
          (t <= 0 || t >= 1 || (to.dx - from.dx).abs() < 1
                  ? DashFacing.front
                  : to.dx < from.dx
                  ? DashFacing.left
                  : DashFacing.right)
              .index;
    }
  }

  /// On the way a bird flaps; before and after it keeps its own pose.
  @override
  void poses(double seconds, Uint8List out) {
    for (var i = 0; i < _birds.length; i++) {
      final t = _local(i);
      out[i] = t > 0 && t < 1 ? DashPose.flying.index : DashFlockPosing.ownPose;
    }
  }
}
