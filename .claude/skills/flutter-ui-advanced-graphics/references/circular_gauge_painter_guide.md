# Custom Circular Gauge Painter Guide

This reference demonstrates building an efficient, hardware-accelerated circular gauge with `CustomPainter` and `RepaintBoundary`.

---

## 1. Performance Rules

1. **RepaintBoundary Wrapper:** Always wrap `CustomPaint` inside `RepaintBoundary` to isolate canvas repaints from ancestor and sibling widgets.
2. **Deterministic `shouldRepaint`:** Compare each relevant property in `shouldRepaint`. Never return `true` unconditionally.
3. **No Dynamic Allocations in Loop:** Create and configure reusable `Paint` properties outside high-frequency loops.

---

## 2. Implementation Pattern

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class const CircularGaugePainter({
  required final double progress, // 0.0 to 1.0
  required final Color trackColor,
  required final Color progressColor,
  final double strokeWidth = 10.0,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from 12 o'clock (-pi / 2)
    const startAngle = -3.141592653589793 / 2;
    final sweepAngle = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class const CircularProgressGauge({
  super.key,
  required final double progress,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(120, 120),
        painter: CircularGaugePainter(
          progress: progress,
          trackColor: colorScheme.surfaceContainerHighest,
          progressColor: colorScheme.primary,
        ),
      ),
    );
  }
}
```
