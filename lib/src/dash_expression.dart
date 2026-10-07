import 'package:flutter/painting.dart';

/// Whether the eyes blink on their own, stay open, or stay shut.
enum DashEyes { blinking, open, closed }

/// What the face says on top of the pose: where the bird looks (each axis
/// -1..1) and its mood, from worried (-1) through calm (0) to happy (1).
class const DashExpression({
  final DashEyes eyes = DashEyes.blinking,
  final Offset look = Offset.zero,
  final double mood = 0,
}) {
  static const calm = DashExpression();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashExpression && other.eyes == eyes && other.look == look && other.mood == mood;

  @override
  int get hashCode => Object.hash(eyes, look, mood);
}
