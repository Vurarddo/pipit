import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/dash_bird.dart';

/// A sphere of evenly spread points with two caps of land and a bird on each.
DashPlanet _planet() {
  const n = 900;
  final lattice = Float32List(n * 3), land = Int16List(n);
  for (var i = 0; i < n; i++) {
    final y = 1 - 2 * (i + 0.5) / n, r = sqrt(1 - y * y), th = i * pi * (3 - sqrt(5));
    lattice.setAll(3 * i, [r * cos(th), y, r * sin(th)]);
    land[i] = y > 0.45 ? 0 : (r * sin(th) > 0.6 ? 1 : -1);
  }
  final bodies = DashPalette.dark.bodies;
  return DashPlanet(
    lattice: lattice,
    land: land,
    landColors: [bodies[0], bodies[3]],
    birdIds: const ['a', 'b'],
    birdPoints: Int32List.fromList([40, n ~/ 2]),
    birdColors: [bodies[0], bodies[3]],
    birdMarks: const [DashPlanetMark.lead, DashPlanetMark.working],
  );
}

void main() {
  late DashPlanetController turn;
  var taps = 0;

  Future<void> host(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    turn = DashPlanetController();
    addTearDown(turn.dispose);
    taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: DashPlanetView(
          planet: _planet(),
          controller: turn,
          semanticLabel: 'planet',
          onTap: () => taps++,
        ),
      ),
    );
  }

  testWidgets('a tap anywhere on the globe opens it; the empty corners do not', (tester) async {
    await host(tester);
    await tester.tapAt(const Offset(200, 200));
    await tester.tapAt(const Offset(80, 200));
    expect(taps, 2);
    await tester.tapAt(const Offset(8, 8));
    expect(taps, 2);
  });

  testWidgets('dragging down brings the top of the planet toward the viewer', (tester) async {
    await host(tester);
    final before = turn.value;
    await tester.drag(find.byType(DashPlanetView), const Offset(0, 60));
    expect(turn.value.tilt, greaterThan(before.tilt));
    await tester.drag(find.byType(DashPlanetView), const Offset(60, 0));
    expect(turn.value.yaw, greaterThan(before.yaw));
  });
}
