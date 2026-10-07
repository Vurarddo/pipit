import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_flock.dart';
import 'package:dash_bird/src/dash_flock_bird.dart';
import 'package:dash_bird/src/dash_flock_painter.dart';
import 'package:dash_bird/src/dash_flock_view.dart';
import 'package:dash_bird/src/dash_hit_grid.dart';
import 'package:dash_bird/src/dash_level.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_palette.dart';
import 'package:dash_bird/src/dash_sprite_sheet.dart';

final _look = DashLook.fromBody(DashPalette.dark.bodies.first, palette: DashPalette.dark);

List<DashFlockBird> _grid(int side, {double gap = 120, double size = 100}) => [
  for (var i = 0; i < side * side; i++)
    DashFlockBird(
      id: 'b$i',
      position: Offset((i % side) * gap + gap / 2, (i ~/ side) * gap + gap / 2),
      size: size,
      look: _look,
      spriteKey: i.isEven ? 'even' : 'odd',
    ),
];

void main() {
  test('levels follow the size on screen', () {
    expect(DashLevels.of(80), DashLevel.live);
    expect(DashLevels.of(30), DashLevel.sprite);
    expect(DashLevels.of(6), DashLevel.dot);
  });

  test('the camera maps both ways and zooms around the pointer', () {
    const camera = DashCamera(offset: Offset(40, 10), zoom: 2);
    expect(camera.toScene(camera.toScreen(const Offset(7, 9))), const Offset(7, 9));
    final zoomed = camera.zoomedAt(const Offset(100, 50), 1.5);
    expect(zoomed.toScene(const Offset(100, 50)), camera.toScene(const Offset(100, 50)));
  });

  test('the grid finds the body under a point, the top one when they overlap', () {
    final grid = DashHitGrid(10)
      ..rebuild(const [Offset(0, 0), Offset(4, 0), Offset(40, 40)], const [5, 5, 5]);
    expect(grid.hit(const Offset(40, 42)), 2);
    expect(grid.hit(const Offset(20, 20)), isNull);
    expect(grid.hit(const Offset(2, 0)), 1);
  });

  test('birds that share a sprite key share a sprite', () {
    final sheet = DashSpriteSheet();
    final birds = _grid(2);
    expect(sheet.spriteFor(birds[0]), sheet.spriteFor(birds[2]));
    expect(sheet.spriteFor(birds[0]), isNot(sheet.spriteFor(birds[1])));
    sheet.dispose();
  });

  test('a flock finds the bird under a scene point', () {
    final flock = DashFlock()..birds = _grid(3);
    final bird = flock.birds[4];
    expect(flock.birdAt(DashFlock.bodyCentre(bird)), 4);
    expect(flock.birdAt(const Offset(0, 0)), isNull);
    flock.dispose();
  });

  Future<(int, int, int)> frame(WidgetTester tester, List<DashFlockBird> birds, double zoom) async {
    final key = GlobalKey();
    final seconds = ValueNotifier(0.5);
    final camera = ValueNotifier(DashCamera(zoom: zoom));
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpWidget(
      MaterialApp(
        home: DashFlockView(
          key: key,
          birds: birds,
          seconds: seconds,
          camera: camera,
          semanticLabel: 'flock',
        ),
      ),
    );
    final painter =
        tester
                .widget<CustomPaint>(
                  find.descendant(of: find.byKey(key), matching: find.byType(CustomPaint)),
                )
                .painter!
            as DashFlockPainter;
    return painter.flock.lastFrame;
  }

  testWidgets('up close at most 150 birds are live, the rest sprites', (tester) async {
    final (live, sprites, dots) = await frame(tester, _grid(20, gap: 40, size: 60), 1);
    expect(live, DashLevels.liveBudget);
    expect(sprites, greaterThan(0));
    expect(dots, 0);
  });

  testWidgets('zoomed out, a thousand birds are sprites and dots only', (tester) async {
    final (live, sprites, dots) = await frame(tester, _grid(32), 0.12);
    expect(live, 0);
    expect(sprites + dots, greaterThan(0));
    expect(dots, greaterThan(0));
  });

  testWidgets('birds off screen are not drawn at all', (tester) async {
    final (live, sprites, dots) = await frame(tester, _grid(32), 1);
    expect(live + sprites + dots, lessThan(32 * 32));
  });
}
