// Draws the picture used by the README and pub.dev:
//
//   flutter test tool/screenshot_test.dart --update-goldens
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/dash_bird.dart';

const _accessories = [
  DashAccessory.cap,
  DashAccessory.crown,
  DashAccessory.headband,
  DashAccessory.helmet,
  DashAccessory.whistle,
  DashAccessory.clock,
  DashAccessory.bag,
];

const _facings = [
  DashFacing.front,
  DashFacing.left,
  DashFacing.front,
  DashFacing.right,
  DashFacing.front,
  DashFacing.back,
  DashFacing.front,
];

Widget _board(DashPalette palette, Color ground, ValueNotifier<double> seconds) => ColoredBox(
  color: ground,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, pose) in DashPose.values.indexed)
              DashView(
                id: 'pose-$i',
                look: DashLook.fromBody(palette.bodies[i], palette: palette),
                semanticLabel: pose.name,
                seconds: seconds,
                size: 120,
                pose: pose,
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, accessory) in _accessories.indexed)
              DashView(
                id: 'worn-$i',
                look: DashLook.fromBody(palette.bodies[(i + 3) % 7], palette: palette),
                semanticLabel: accessory.name,
                seconds: seconds,
                size: 120,
                facing: _facings[i],
                accessory: accessory,
              ),
          ],
        ),
      ],
    ),
  ),
);

void main() {
  testWidgets('screenshot', (tester) async {
    tester.view
      ..physicalSize = const Size(1776, 1088)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final seconds = ValueNotifier(1.3);
    addTearDown(seconds.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: Column(
            children: [
              _board(DashPalette.light, const Color(0xFFF4F6FA), seconds),
              _board(DashPalette.dark, const Color(0xFF0F1218), seconds),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../doc/dash_bird.png'),
    );
  });
}
