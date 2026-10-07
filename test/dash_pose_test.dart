import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_expression.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_palette.dart';
import 'package:dash_bird/src/dash_pose.dart';
import 'package:dash_bird/src/dash_pose_transition.dart';
import 'package:dash_bird/src/dash_reactions.dart';
import 'package:dash_bird/src/dash_renderer.dart';
import 'package:dash_bird/src/dash_view.dart';

List<double> _numbers(DashPoseValues v) => [
  v.crouch,
  v.tilt,
  v.spread,
  v.flap,
  v.step,
  v.lid,
  v.eyeScale,
  v.tuft,
  v.lookX,
  v.lookY,
  v.mood,
];

void _expectClose(DashPoseValues a, DashPoseValues b, double tolerance, String reason) {
  final x = _numbers(a);
  final y = _numbers(b);
  for (var i = 0; i < x.length; i++) {
    expect(x[i], closeTo(y[i], tolerance), reason: '$reason, value $i');
  }
}

const _px = 120;
final _look = DashLook.fromBody(DashPalette.light.bodies.first, palette: DashPalette.light);

Future<Uint8List> _render(DashFacing facing, DashAccessory accessory, DashMotion motion) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const b = DashRenderer.bounds;
  final unit = _px / (b.width > b.height ? b.width : b.height);
  canvas.translate(_px / 2, _px / 2);
  canvas.scale(unit);
  canvas.translate(-b.center.dx, -b.center.dy);
  DashRenderer().paint(canvas, _look, motion, facing: facing, accessory: accessory);
  final image = await recorder.endRecording().toImage(_px, _px);
  return (await image.toByteData())!.buffer.asUint8List();
}

void main() {
  group('transitions', () {
    test('every pose is reached from every other without a jump', () {
      for (final from in DashPose.values) {
        for (final to in DashPose.values) {
          final transition = DashPoseTransition(DashPoseValues.of(from));
          final before = transition.at(10);
          transition.retarget(DashPoseValues.of(to), 10);
          _expectClose(
            transition.at(10),
            before,
            1e-9,
            '${from.name} → ${to.name} starts in place',
          );
          var previous = transition.at(10);
          for (var t = 10 + 1 / 60; t < 11; t += 1 / 60) {
            final now = transition.at(t);
            _expectClose(now, previous, 0.12, '${from.name} → ${to.name} at $t');
            previous = now;
          }
          _expectClose(transition.at(11), DashPoseValues.of(to), 1e-3, '${to.name} settles');
        }
      }
    });

    test('a change mid-way continues from where the bird is', () {
      final transition = DashPoseTransition(DashPoseValues.of(DashPose.standing));
      transition.retarget(DashPoseValues.of(DashPose.flying), 1);
      final midway = transition.at(1.1);
      transition.retarget(DashPoseValues.of(DashPose.sleeping), 1.1);
      _expectClose(transition.at(1.1), midway, 1e-9, 'interrupted');
    });
  });

  group('expressions', () {
    test('shut eyes stay shut, open eyes do not blink', () {
      final shut = DashPoseValues.of(
        DashPose.standing,
        const DashExpression(eyes: DashEyes.closed),
      ).over(const DashMotion(), 1, 0, blink: false);
      expect(shut.eyeOpen, lessThan(0.1));
      final open = DashPoseValues.of(DashPose.standing).over(
        const DashMotion(eyeOpen: 0.08),
        1,
        0,
        blink: false,
      );
      expect(open.eyeOpen, 1);
    });

    test('look and mood reach the face, clamped', () {
      final motion = DashPoseValues.of(
        DashPose.working,
        const DashExpression(look: Offset(2, 0), mood: -3),
      ).over(const DashMotion(), 0, 0, blink: true);
      expect(motion.look.dx, 1);
      expect(motion.look.dy, closeTo(0.6, 1e-9));
      expect(motion.mood, -1);
    });
  });

  testWidgets('every pose, with anything worn, hopping or squashed, stays inside the bounds', (
    tester,
  ) async {
    for (final pose in DashPose.values) {
      for (final t in const [0.07, 0.21]) {
        // The worst case: a hop at its height and a squash at its deepest.
        final reactions = DashReactions()
          ..hop(t - 0.175)
          ..squash(t - 0.1);
        final motion = reactions.apply(
          DashPoseValues.of(pose).over(const DashMotion(breath: 1), t, 0, blink: false),
          t,
        );
        for (final facing in DashFacing.values) {
          for (final accessory in DashAccessory.values) {
            final rgba = (await tester.runAsync(() => _render(facing, accessory, motion)))!;
            for (var i = 0; i < _px; i++) {
              for (final (x, y) in [(i, 0), (i, _px - 1), (0, i), (_px - 1, i)]) {
                expect(
                  rgba[(y * _px + x) * 4 + 3],
                  0,
                  reason: '${pose.name} ${facing.name} ${accessory.name} at $t touches ($x, $y)',
                );
              }
            }
          }
        }
      }
    }
  });

  testWidgets('a bird without a clock still shows its new pose', (tester) async {
    final key = GlobalKey();
    Future<Uint8List> shot(DashPose pose) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: DashView(id: 'a', look: _look, semanticLabel: 'a', pose: pose, size: 100),
          ),
        ),
      );
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        return (await image.toByteData())!.buffer.asUint8List();
      }))!;
    }

    final standing = await shot(DashPose.standing);
    final sitting = await shot(DashPose.sitting);
    expect(listEquals(standing, sitting), isFalse);
  });
}
