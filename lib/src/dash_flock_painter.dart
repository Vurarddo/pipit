import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_flock.dart';
import 'package:dash_bird/src/dash_flock_focus.dart';
import 'package:dash_bird/src/dash_geometry.dart';
import 'package:dash_bird/src/dash_level.dart';
import 'package:dash_bird/src/dash_renderer.dart';
import 'package:dash_bird/src/dash_sprite_sheet.dart';

/// Draws a whole flock in one pass: birds off screen are
/// skipped, big ones are drawn live up to [DashLevels.liveBudget], the rest
/// as sprites in one atlas call, and the tiniest as dots in another.
class DashFlockPainter({
  required final DashFlock flock,
  required final ValueListenable<double> seconds,
  required final ValueListenable<DashCamera> camera,
  final ValueListenable<DashFlockFocus?>? focus,
}) extends CustomPainter {
  this : super(repaint: Listenable.merge([seconds, camera, focus]));

  final DashRenderer _renderer = DashRenderer();
  final Paint _atlas = Paint()..filterQuality = FilterQuality.low;
  final Paint _links = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final view = Offset.zero & size;
    final cam = camera.value;
    final t = seconds.value;
    final birds = flock.birds;
    flock.move(t);
    final lit = focus?.value;
    lit?.paintLinks(canvas, _links, cam.zoom, (i) => cam.toScreen(flock.at(i)));
    var sprites = 0;
    var dots = 0;
    var live = 0;
    for (var i = 0; i < birds.length; i++) {
      final px = birds[i].size * cam.zoom * flock.scaleOf(i);
      final at = cam.toScreen(flock.at(i));
      flock.pixels[i] = px > 0 && view.overlaps(Rect.fromCenter(center: at, width: px, height: px))
          ? px
          : -1;
      // A faded bird is drawn as a sprite: only sprites and dots fade cheaply.
      final faded = lit != null && !lit.lit.contains(i);
      if (DashLevels.of(px) == DashLevel.live && flock.pixels[i] > 0 && !faded) {
        flock.liveOrder[live++] = i;
      }
    }
    // Over budget, the biggest birds stay live and the rest become sprites
    // (the only allocation of a frame, and only when zoomed into a crowd).
    final order = live > DashLevels.liveBudget
        ? (flock.liveOrder.sublist(0, live)
            ..sort((a, b) => flock.pixels[b].compareTo(flock.pixels[a])))
        : flock.liveOrder;
    final liveCount = live > DashLevels.liveBudget ? DashLevels.liveBudget : live;
    flock.liveMask.fillRange(0, birds.length, 0);
    for (var k = 0; k < liveCount; k++) {
      flock.liveMask[order[k]] = 1;
    }
    for (var i = 0; i < birds.length; i++) {
      final px = flock.pixels[i];
      if (px < 0 || flock.liveMask[i] == 1) continue;
      final at = cam.toScreen(flock.at(i));
      if (px >= DashLevels.spritePixels) {
        final breath = 1 + 0.012 * flock.idle(i).at(t).breath;
        if (lit != null) flock.spriteColors[sprites] = lit.tint(i);
        _place(
          flock.spriteTransforms,
          flock.spriteRects,
          sprites++,
          at,
          px * breath,
          flock.spriteNow(i),
        );
      } else {
        final r = px * DashGeometry.bodyRadius / DashGeometry.bounds.width * 2;
        _place(flock.dotTransforms, flock.dotRects, dots, at, r, flock.sheet.disc);
        final body = birds[i].look.body.toARGB32();
        flock.dotColors[dots++] = lit == null ? body : lit.fade(i, body);
      }
    }
    final sheet = flock.sheet.image;
    if (sprites > 0) {
      canvas.drawRawAtlas(
        sheet,
        Float32List.sublistView(flock.spriteTransforms, 0, sprites * 4),
        Float32List.sublistView(flock.spriteRects, 0, sprites * 4),
        lit == null ? null : Int32List.sublistView(flock.spriteColors, 0, sprites),
        lit == null ? null : BlendMode.modulate,
        null,
        _atlas,
      );
    }
    if (dots > 0) {
      canvas.drawRawAtlas(
        sheet,
        Float32List.sublistView(flock.dotTransforms, 0, dots * 4),
        Float32List.sublistView(flock.dotRects, 0, dots * 4),
        Int32List.sublistView(flock.dotColors, 0, dots),
        BlendMode.modulate,
        null,
        _atlas,
      );
    }
    for (var k = 0; k < liveCount; k++) {
      _paintLive(canvas, flock, order[k], cam, t);
    }
    flock.lastFrame = (liveCount, sprites, dots);
  }

  void _paintLive(Canvas canvas, DashFlock flock, int i, DashCamera cam, double t) {
    final bird = flock.birds[i];
    final idle = flock.idle(i);
    const b = DashGeometry.bounds;
    canvas.save();
    final at = cam.toScreen(flock.at(i));
    canvas.translate(at.dx, at.dy);
    canvas.scale(DashFlock.unit(bird.size) * cam.zoom * flock.scaleOf(i));
    canvas.translate(-b.center.dx, -b.center.dy);
    final motion = flock.poseNow(i).over(idle.at(t), t, idle.phase, blink: true);
    _renderer.paint(
      canvas,
      bird.look,
      motion,
      facing: flock.facingOf(i),
      accessory: bird.accessory,
    );
    canvas.restore();
  }

  /// One RSTransform and source rect: the sprite's cell scaled to [pixels].
  static void _place(
    Float32List transforms,
    Float32List rects,
    int k,
    Offset at,
    double pixels,
    Rect src,
  ) {
    final scale = pixels / DashSpriteSheet.cell;
    transforms
      ..[k * 4] = scale
      ..[k * 4 + 1] = 0
      ..[k * 4 + 2] = at.dx - scale * src.width / 2
      ..[k * 4 + 3] = at.dy - scale * src.height / 2;
    rects
      ..[k * 4] = src.left
      ..[k * 4 + 1] = src.top
      ..[k * 4 + 2] = src.right
      ..[k * 4 + 3] = src.bottom;
  }

  @override
  bool shouldRepaint(DashFlockPainter old) => old.flock != flock || old.focus != focus;
}
