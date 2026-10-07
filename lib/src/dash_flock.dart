import 'dart:typed_data';

import 'package:flutter/painting.dart';

import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_flock_bird.dart';
import 'package:dash_bird/src/dash_flock_motion.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_hit_grid.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_pose.dart';
import 'package:dash_bird/src/dash_sprite_sheet.dart';

/// A flock's lasting state between frames: the birds with their rhythm and
/// pose, the sprite sheet, the hit grid and the draw buffers, so a frame of
/// an unchanged flock allocates nothing.
class DashFlock {
  List<DashFlockBird> _birds = const [];
  List<DashIdle> _idles = const [];
  List<DashPoseValues> _poses = const [];
  List<Rect> _sprites = const [];
  final DashSpriteSheet sheet = DashSpriteSheet();
  final DashHitGrid _grid = DashHitGrid(1);

  // Draw buffers, grown when the flock grows and reused every frame.
  Float32List spriteTransforms = Float32List(0);
  Float32List spriteRects = Float32List(0);
  Float32List dotTransforms = Float32List(0);
  Float32List dotRects = Float32List(0);
  Int32List dotColors = Int32List(0);
  Int32List spriteColors = Int32List(0);
  List<int> liveOrder = [];
  Uint8List liveMask = Uint8List(0);

  /// How the last frame drew the flock: live birds, sprites, dots.
  (int, int, int) lastFrame = (0, 0, 0);
  List<double> pixels = [];

  /// Moves the birds around their positions; `null` keeps them still.
  DashFlockMotion? motion;
  Float32List _offsets = Float32List(0);
  Float32List _scales = Float32List(0);
  Uint8List _facings = Uint8List(0);
  Uint8List _posed = Uint8List(0);
  List<Rect?> _turned = const [];

  List<DashFlockBird> get birds => _birds;

  /// Where bird [i] is this frame: its position plus the last [move].
  Offset at(int i) => motion == null
      ? _birds[i].position
      : _birds[i].position.translate(_offsets[2 * i], _offsets[2 * i + 1]);

  /// Which way bird [i] faces this frame: its motion's say, else its own.
  DashFacing facingOf(int i) =>
      motion is DashFlockFacing ? DashFacing.values[_facings[i]] : _birds[i].facing;

  /// Bird [i]'s sprite as it faces this frame; each turned sprite is drawn
  /// into the sheet the first time it is needed.
  Rect spriteNow(int i) {
    final facing = facingOf(i);
    if (facing == _birds[i].facing) return _sprites[i];
    final k = i * 4 + facing.index;
    return _turned[k] ??= sheet.spriteFor(_turnedBird(_birds[i], facing));
  }

  static DashFlockBird _turnedBird(DashFlockBird b, DashFacing facing) => DashFlockBird(
    id: b.id,
    position: b.position,
    size: b.size,
    look: b.look,
    spriteKey: '${b.spriteKey}@${facing.name}',
    facing: facing,
    accessory: b.accessory,
    pose: b.pose,
  );

  /// Bird [i]'s pose this frame: its motion's say (walking, flying), else
  /// its own. Values are shared per pose, so a frame allocates nothing.
  DashPoseValues poseNow(int i) {
    if (motion is! DashFlockPosing) return _poses[i];
    final p = _posed[i];
    return p == DashFlockPosing.ownPose ? _poses[i] : _byPose[p];
  }

  static final List<DashPoseValues> _byPose = [
    for (final pose in DashPose.values) DashPoseValues.of(pose),
  ];

  /// Bird [i]'s size factor this frame (1 unless the motion scales birds).
  double scaleOf(int i) => motion is DashFlockScaling ? _scales[i] : 1;

  /// Advances [motion] to [seconds]; called once at the start of a frame.
  void move(double seconds) {
    final m = motion;
    if (m == null) return;
    m.offsets(seconds, _offsets);
    if (m is DashFlockScaling) m.scales(seconds, _scales);
    if (m is DashFlockFacing) m.facings(seconds, _facings);
    if (m is DashFlockPosing) m.poses(seconds, _posed);
  }

  DashIdle idle(int i) => _idles[i];

  Rect sprite(int i) => _sprites[i];

  set birds(List<DashFlockBird> birds) {
    if (identical(birds, _birds)) return;
    _birds = birds;
    _idles = [for (final b in birds) DashIdle(b.id)];
    _poses = [for (final b in birds) DashPoseValues.of(b.pose)];
    _sprites = [for (final b in birds) sheet.spriteFor(b)];
    final n = birds.length;
    if (spriteTransforms.length < n * 4) {
      spriteTransforms = Float32List(n * 4);
      spriteRects = Float32List(n * 4);
      dotTransforms = Float32List(n * 4);
      dotRects = Float32List(n * 4);
      dotColors = Int32List(n);
      spriteColors = Int32List(n);
    }
    _offsets = Float32List(n * 2);
    _scales = Float32List(n)..fillRange(0, n, 1);
    _facings = Uint8List.fromList([for (final b in birds) b.facing.index]);
    _turned = List.filled(n * 4, null);
    _posed = Uint8List(n)..fillRange(0, n, DashFlockPosing.ownPose);
    liveOrder = List.filled(n, 0);
    liveMask = Uint8List(n);
    pixels = List.filled(n, 0);
    _grid.rebuild([for (final b in birds) bodyCentre(b)], [for (final b in birds) bodyRadius(b)]);
  }

  /// The bird whose body is under [scene], or `null`. Moving birds are
  /// looked for where the last frame drew them.
  int? birdAt(Offset scene) {
    if (motion != null) {
      _grid.rebuild(
        [
          for (var i = 0; i < _birds.length; i++)
            at(i) - DashGeometry.bounds.center * unit(_birds[i].size),
        ],
        [for (final b in _birds) bodyRadius(b)],
      );
    }
    return _grid.hit(scene);
  }

  void dispose() => sheet.dispose();

  /// Scene units per body unit for a bird of [size]: the box fits the bounds.
  static double unit(double size) => size / DashGeometry.bounds.width;

  static Offset bodyCentre(DashFlockBird b) =>
      b.position - DashGeometry.bounds.center * unit(b.size);

  static double bodyRadius(DashFlockBird b) => DashGeometry.bodyRadius * unit(b.size);
}
