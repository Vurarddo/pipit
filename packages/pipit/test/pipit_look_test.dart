import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:pipit/pipit.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  test('the same id always gets the same look', () {
    expect(PipitLook.of('robin'), PipitLook.of('robin'));
    expect(PipitLook.of('robin').hashCode, PipitLook.of('robin').hashCode);
  });

  test('a flock of ids spreads over the palette', () {
    final bodies = {for (var i = 0; i < 100; i++) PipitLook.of('bird-$i').body};
    expect(bodies.length, greaterThan(PipitPalette.light.bodies.length ~/ 2));
    expect(PipitPalette.light.bodies, containsAll(bodies));
  });

  test('wing, mask and outline follow the body', () {
    const body = Color(0xFF2563EB);
    final look = PipitLook.fromBody(body);
    expect(look.body, body);
    expect(look.wing, isNot(body));
    expect(look.mask, isNot(body));
    expect(look.outline, PipitPalette.light.ink);
    expect(
      PipitLook.fromBody(body, palette: PipitPalette.dark).outline,
      isNot(PipitPalette.dark.ink),
    );
  });

  test('every bird stands out from its outline in both palettes', () {
    for (final palette in [PipitPalette.light, PipitPalette.dark]) {
      for (final body in palette.bodies) {
        final look = PipitLook.fromBody(body, palette: palette);
        expect(_contrast(look.body, look.outline), greaterThan(1.8), reason: '$body');
      }
    }
  });

  testWidgets('the palette follows the theme', (tester) async {
    late PipitPalette palette;
    Widget app(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          palette = PipitPalette.of(context);
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(app(ThemeData.dark()));
    expect(palette, same(PipitPalette.dark));

    final mine = PipitPalette.light.copyWith(belly: const Color(0xFFFFF7E0));
    await tester.pumpWidget(app(ThemeData.light().copyWith(extensions: [mine])));
    await tester.pumpAndSettle();
    expect(palette.belly, mine.belly);
  });
}
