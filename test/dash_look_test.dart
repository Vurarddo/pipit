import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/dash_bird.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  test('the same id always gets the same look', () {
    expect(DashLook.of('robin'), DashLook.of('robin'));
    expect(DashLook.of('robin').hashCode, DashLook.of('robin').hashCode);
  });

  test('a flock of ids spreads over the palette', () {
    final bodies = {for (var i = 0; i < 100; i++) DashLook.of('bird-$i').body};
    expect(bodies.length, greaterThan(DashPalette.light.bodies.length ~/ 2));
    expect(DashPalette.light.bodies, containsAll(bodies));
  });

  test('wing, mask and outline follow the body', () {
    const body = Color(0xFF2563EB);
    final look = DashLook.fromBody(body);
    expect(look.body, body);
    expect(look.wing, isNot(body));
    expect(look.mask, isNot(body));
    expect(look.outline, DashPalette.light.ink);
    expect(DashLook.fromBody(body, palette: DashPalette.dark).outline, isNot(DashPalette.dark.ink));
  });

  test('every bird stands out from its outline in both palettes', () {
    for (final palette in [DashPalette.light, DashPalette.dark]) {
      for (final body in palette.bodies) {
        final look = DashLook.fromBody(body, palette: palette);
        expect(_contrast(look.body, look.outline), greaterThan(1.8), reason: '$body');
      }
    }
  });

  testWidgets('the palette and terrain follow the theme', (tester) async {
    late DashPalette palette;
    late DashTerrain terrain;
    Widget app(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          palette = DashPalette.of(context);
          terrain = DashTerrain.of(context);
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(app(ThemeData.dark()));
    expect(palette, same(DashPalette.dark));
    expect(terrain, same(DashTerrain.dark));

    final mine = DashPalette.light.copyWith(belly: const Color(0xFFFFF7E0));
    await tester.pumpWidget(app(ThemeData.light().copyWith(extensions: [mine])));
    await tester.pumpAndSettle();
    expect(palette.belly, mine.belly);
    expect(terrain, same(DashTerrain.light));
  });
}
