import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_flock_bird.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_pose.dart';
import 'package:dash_bird/src/dash_renderer.dart';

/// Every distinct small bird drawn once, side by side in one image, plus a
/// white disc for dots: the flock draws all its sprites and all its dots in
/// one `drawRawAtlas` each. Rebuilt only when a new sprite key appears.
class DashSpriteSheet {
  /// Pixels per sprite cell: sharp up to [DashLevels.livePixels] on screen.
  static const double cell = 64;

  /// Cells per row of the sheet: 2048 px wide, well inside any GPU's limit
  /// however many looks, poses and facings a flock has.
  static const int _columns = 32;

  static Rect _cellOf(int slot) =>
      Rect.fromLTWH((slot % _columns) * cell, (slot ~/ _columns) * cell, cell, cell);

  final Map<String, int> _slots = {'': 0};
  final List<DashFlockBird?> _sources = [null];
  final DashRenderer _renderer = DashRenderer();
  ui.Image? _image;

  ui.Image get image => _image ??= _build();

  /// The disc dots are drawn from.
  Rect get disc => const Rect.fromLTWH(0, 0, cell, cell);

  Rect spriteFor(DashFlockBird bird) {
    final slot = _slots[bird.spriteKey];
    if (slot != null) return _cellOf(slot);
    _slots[bird.spriteKey] = _sources.length;
    _sources.add(bird);
    _image?.dispose();
    _image = null;
    return _cellOf(_sources.length - 1);
  }

  void dispose() {
    _image?.dispose();
    _image = null;
  }

  ui.Image _build() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // White is not a colour anyone sees: the disc is a mask each dot tints
    // with its bird's body colour (`BlendMode.modulate`).
    canvas.drawCircle(
      const Offset(cell / 2, cell / 2),
      cell / 2,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    const b = DashGeometry.bounds;
    final unit = cell / b.width;
    for (var i = 1; i < _sources.length; i++) {
      final bird = _sources[i]!;
      canvas.save();
      final at = _cellOf(i).center;
      canvas.translate(at.dx, at.dy);
      canvas.scale(unit);
      canvas.translate(-b.center.dx, -b.center.dy);
      final motion = DashPoseValues.of(bird.pose).over(DashMotion.rest, 0, 0, blink: false);
      _renderer.paint(canvas, bird.look, motion, facing: bird.facing, accessory: bird.accessory);
      canvas.restore();
    }
    final columns = _sources.length < _columns ? _sources.length : _columns;
    final rows = (_sources.length + _columns - 1) ~/ _columns;
    return recorder.endRecording().toImageSync((cell * columns).ceil(), (cell * rows).ceil());
  }
}
