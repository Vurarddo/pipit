import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'package:pipit/src/stable_hash.dart';

/// Everything that moves a bird at one moment, in body units and radians,
/// applied by the views to the rest pose: idle life (breath, blinks, a wing
/// sway) and the pose and expression on top of it.
class const PipitMotion({
  final double breath = 0,
  final double eyeOpen = 1,
  final double wing = 0,
  final double lift = 0,
  final double crouch = 0,
  final double tilt = 0,
  final double leftStep = 0,
  final double rightStep = 0,
  final double eyeScale = 1,
  final Offset look = Offset.zero,
  final double mood = 0,
  final double tuft = 0,
  final double squash = 0,
}) {
  static const rest = PipitMotion();
}

/// Idle life of one bird, derived only from its id and the time, so the same
/// bird looks the same at the same second in every run, preview and golden.
class PipitIdle(String id) {
  this
    : _seed = StableHash.seed(id),
      _phase = StableHash.unit(StableHash.seed(id), 1) * 2 * math.pi,
      _breathRate = 1.5 + StableHash.unit(StableHash.seed(id), 2) * 1.1,
      _blinkSlot = 3.4 + StableHash.unit(StableHash.seed(id), 3) * 1.6,
      _driftRate = 0.1 + StableHash.unit(StableHash.seed(id), 4) * 0.15,
      _driftPhase = StableHash.unit(StableHash.seed(id), 5) * 2 * math.pi;

  final int _seed;
  final double _phase;
  final double _breathRate;
  final double _blinkSlot;

  // The breathing tempo wanders slowly, each bird at its own pace, so two
  // birds whose base rates happen to match still drift apart.
  final double _driftRate;
  final double _driftPhase;

  /// Offsets the walk and the wing beat, so a flock never moves in step.
  double get phase => _phase;

  // A blink takes 0.14 s once in every slot of 3.4–5 s, its own length per
  // bird so that two birds drift apart, at a jittered point in the slot.
  static const double _blink = 0.14;

  PipitMotion at(double seconds) {
    final drift = 0.8 * math.sin(seconds * _driftRate + _driftPhase);
    final breath = math.sin(seconds * _breathRate + _phase + drift);
    return PipitMotion(
      breath: breath,
      eyeOpen: _eyeOpen(seconds),
      wing: 0.05 * math.sin(seconds * _breathRate * 0.5 + _phase * 1.3) + _twitch(seconds),
    );
  }

  // Now and then a wing twitches: once in each 7 s slot, for a quarter second.
  static const double _twitchSlot = 7;
  static const double _twitchTime = 0.25;
  static const double _twitchReach = 0.3;

  double _twitch(double seconds) {
    final shifted = seconds + _phase * 2;
    final slot = (shifted / _twitchSlot).floor();
    final start =
        slot * _twitchSlot +
        StableHash.unit(_seed ^ 0x5BD1E995, slot) * (_twitchSlot - _twitchTime);
    final k = (shifted - start) / _twitchTime;
    if (k < 0 || k > 1) return 0;
    return _twitchReach * math.sin(k * math.pi * 2).abs() * (1 - k);
  }

  double _eyeOpen(double seconds) {
    final shifted = seconds + _phase;
    final slot = (shifted / _blinkSlot).floor();
    final start = slot * _blinkSlot + StableHash.unit(_seed, slot) * (_blinkSlot - _blink);
    final k = (shifted - start) / _blink;
    if (k < 0 || k > 1) return 1;
    return math.max(0.08, 1 - math.sin(k * math.pi));
  }
}
