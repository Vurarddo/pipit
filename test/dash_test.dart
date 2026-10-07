import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_palette.dart';
import 'package:dash_bird/src/dash_renderer.dart';
import 'package:dash_bird/src/dash_stage.dart';
import 'package:dash_bird/src/dash_view.dart';

List<double> _blinkStarts(DashIdle idle, double until) {
  final starts = <double>[];
  var closed = false;
  for (var t = 0.0; t < until; t += 0.01) {
    final now = idle.at(t).eyeOpen < 0.5;
    if (now && !closed) starts.add(t);
    closed = now;
  }
  return starts;
}

const _px = 120;

/// Paints one view of the bird fitted to [DashRenderer.bounds] on a
/// transparent square and returns its RGBA bytes.
Future<Uint8List> _render(DashFacing facing, [DashAccessory accessory = DashAccessory.none]) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const b = DashRenderer.bounds;
  final unit = _px / (b.width > b.height ? b.width : b.height);
  canvas.translate(_px / 2, _px / 2);
  canvas.scale(unit);
  canvas.translate(-b.center.dx, -b.center.dy);
  DashRenderer().paint(
    canvas,
    DashLook.fromBody(DashPalette.light.bodies.first, palette: DashPalette.light),
    DashMotion.rest,
    facing: facing,
    accessory: accessory,
  );
  final image = await recorder.endRecording().toImage(_px, _px);
  final data = await image.toByteData();
  return data!.buffer.asUint8List();
}

int _alpha(Uint8List rgba, int x, int y) => rgba[(y * _px + x) * 4 + 3];

void main() {
  group('views', () {
    testWidgets('every view and accessory stays inside the shared bounds', (tester) async {
      for (final facing in DashFacing.values) {
        for (final accessory in DashAccessory.values) {
          final rgba = (await tester.runAsync(() => _render(facing, accessory)))!;
          for (var i = 0; i < _px; i++) {
            for (final (x, y) in [(i, 0), (i, _px - 1), (0, i), (_px - 1, i)]) {
              expect(
                _alpha(rgba, x, y),
                0,
                reason: '${facing.name} with ${accessory.name} touches the edge at ($x, $y)',
              );
            }
          }
        }
      }
    });

    testWidgets('every accessory shows in every view it belongs to', (tester) async {
      for (final facing in DashFacing.values) {
        final bare = (await tester.runAsync(() => _render(facing)))!;
        for (final accessory in DashAccessory.values.where((a) => a != DashAccessory.none)) {
          final dressed = (await tester.runAsync(() => _render(facing, accessory)))!;
          expect(listEquals(bare, dressed), isFalse, reason: '${accessory.name}, ${facing.name}');
        }
      }
    });

    testWidgets('front, side and back are different drawings', (tester) async {
      final front = (await tester.runAsync(() => _render(DashFacing.front)))!;
      final left = (await tester.runAsync(() => _render(DashFacing.left)))!;
      final back = (await tester.runAsync(() => _render(DashFacing.back)))!;
      expect(listEquals(front, left), isFalse);
      expect(listEquals(front, back), isFalse);
      expect(listEquals(left, back), isFalse);
    });

    testWidgets('right is the left view mirrored', (tester) async {
      final left = (await tester.runAsync(() => _render(DashFacing.left)))!;
      final right = (await tester.runAsync(() => _render(DashFacing.right)))!;
      var mismatched = 0;
      for (var y = 0; y < _px; y++) {
        for (var x = 0; x < _px; x++) {
          if ((_alpha(left, x, y) - _alpha(right, _px - 1 - x, y)).abs() > 8) mismatched++;
        }
      }
      // Anti-aliasing may differ on a few edge pixels, never on the shape.
      expect(mismatched, lessThan(_px * _px ~/ 200));
    });
  });

  group('DashIdle', () {
    test('the same bird moves the same way at the same second', () {
      final a = DashIdle('testing-bloc').at(12.34);
      final b = DashIdle('testing-bloc').at(12.34);
      expect(a.breath, b.breath);
      expect(a.eyeOpen, b.eyeOpen);
      expect(a.wing, b.wing);
    });

    test('two birds never breathe in step', () {
      final a = DashIdle('flutter-ui-hub');
      final b = DashIdle('testing-bloc');
      final apart = [
        for (var t = 0.0; t < 10; t += 0.5) (a.at(t).breath - b.at(t).breath).abs() > 0.05,
      ];
      expect(apart.where((x) => x).length, greaterThan(apart.length ~/ 2));
    });

    test('a bird blinks every 3.4–5 seconds, at its own moments', () {
      final a = _blinkStarts(DashIdle('flutter-ui-hub'), 40);
      final b = _blinkStarts(DashIdle('testing-bloc'), 40);
      expect(a.length, inInclusiveRange(8, 12));
      expect(b.length, inInclusiveRange(8, 12));
      final together = a.where((t) => b.any((u) => (t - u).abs() < 0.1)).length;
      expect(together, lessThan(a.length ~/ 2));
    });

    test('eyes never close completely', () {
      final idle = DashIdle('x');
      for (var t = 0.0; t < 20; t += 0.005) {
        expect(idle.at(t).eyeOpen, inInclusiveRange(0.08, 1));
      }
    });
  });

  group('DashStage', () {
    Widget host(Widget child, {bool reduceMotion = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

    ValueListenable<double>? clock;
    Widget stage() => DashStage(
      builder: (context, seconds) {
        clock = seconds;
        return const SizedBox();
      },
    );

    testWidgets('advances with frames', (tester) async {
      await tester.pumpWidget(host(stage()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(clock!.value, closeTo(0.5, 0.02));
    });

    testWidgets('a hidden stage stops its clock', (tester) async {
      await tester.pumpWidget(host(TickerMode(enabled: false, child: stage())));
      await tester.pump(const Duration(seconds: 1));
      expect(clock!.value, 0);
    });

    testWidgets('reduced motion keeps the birds at rest', (tester) async {
      await tester.pumpWidget(host(stage(), reduceMotion: true));
      await tester.pump(const Duration(seconds: 1));
      expect(clock!.value, 0);
    });
  });

  testWidgets('a bird is announced by its label in both themes', (tester) async {
    for (final theme in [ThemeData.light(), ThemeData.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => DashView(
              id: 'a',
              look: DashLook.of('a', palette: DashPalette.of(context)),
              semanticLabel: 'Dash the bird',
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Dash the bird'), findsOneWidget);
    }
  });
}
