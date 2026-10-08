import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';
import 'package:pipit/src/pipit_palette.dart';
import 'package:pipit/src/pipit_reactions.dart';
import 'package:pipit/src/pipit_stage.dart';
import 'package:pipit/src/pipit_view.dart';

List<double> _blinkStarts(PipitIdle idle) {
  final starts = <double>[];
  var closed = false;
  for (var t = 0.0; t < 300; t += 1 / 60) {
    final now = idle.at(t).eyeOpen < 0.5;
    if (now && !closed) starts.add(t);
    closed = now;
  }
  return starts;
}

void main() {
  group('a flock of 20 never moves in step', () {
    final birds = [for (var i = 0; i < 20; i++) PipitIdle('skill-$i')];

    test('breathing drifts apart for every pair', () {
      for (var a = 0; a < birds.length; a++) {
        for (var b = a + 1; b < birds.length; b++) {
          var apart = 0.0;
          for (var t = 0.0; t < 60; t += 0.1) {
            final d = (birds[a].at(t).breath - birds[b].at(t).breath).abs();
            if (d > apart) apart = d;
          }
          expect(apart, greaterThan(0.5), reason: 'skill-$a and skill-$b breathe together');
        }
      }
    });

    test('no two birds share more than a fifth of their blinks over five minutes', () {
      final starts = [for (final b in birds) _blinkStarts(b)];
      for (var a = 0; a < birds.length; a++) {
        for (var b = a + 1; b < birds.length; b++) {
          final together = starts[a].where((t) => starts[b].any((u) => (t - u).abs() < 0.1)).length;
          expect(
            together,
            lessThan(starts[a].length ~/ 3),
            reason: 'skill-$a and skill-$b blink together',
          );
        }
      }
    });

    test('each bird twitches a wing now and then, at its own moments', () {
      List<double> twitches(PipitIdle idle) => [
        for (var t = 0.0; t < 30; t += 1 / 60)
          if (idle.at(t).wing > 0.12) t,
      ];
      final first = twitches(birds[0]);
      final second = twitches(birds[1]);
      expect(first, isNotEmpty);
      expect(second, isNotEmpty);
      expect(first.first, isNot(closeTo(second.first, 0.2)));
    });
  });

  group('reactions', () {
    test('a hop rises and flutters, then lands', () {
      final reactions = PipitReactions()..hop(1);
      final peak = reactions.apply(const PipitMotion(), 1.175);
      expect(peak.lift, greaterThan(0.04));
      expect(reactions.apply(const PipitMotion(), 1.4).lift, 0);
      expect(reactions.apply(const PipitMotion(), 0.9).lift, 0);
    });

    test('a squash dips and comes back', () {
      final reactions = PipitReactions()..squash(2);
      expect(reactions.apply(const PipitMotion(), 2.1).squash, greaterThan(0.05));
      expect(reactions.apply(const PipitMotion(), 2.4).squash, 0);
    });
  });

  testWidgets('a hidden stage schedules no frames', (tester) async {
    await tester.pumpWidget(
      TickerMode(
        enabled: false,
        child: PipitStage(builder: (context, seconds) => const SizedBox()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('eyes follow the pointer across the stage', (tester) async {
    final key = GlobalKey();
    final look = PipitLook.fromBody(PipitPalette.light.bodies.first, palette: PipitPalette.light);
    await tester.pumpWidget(
      MaterialApp(
        home: PipitStage(
          builder: (context, seconds) => Center(
            child: RepaintBoundary(
              key: key,
              child: PipitView(
                id: 'a',
                look: look,
                semanticLabel: 'a',
                seconds: seconds,
                size: 120,
              ),
            ),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    Future<Uint8List> lookingAt(Offset at) async {
      await mouse.moveTo(at);
      // Past the hop the arrival starts, and long enough for the gaze to settle.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 16));
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
      }))!;
    }

    final center = tester.getCenter(find.byKey(key));
    final left = await lookingAt(center.translate(-400, 0));
    final right = await lookingAt(center.translate(400, 0));
    expect(listEquals(left, right), isFalse);
  });
}
