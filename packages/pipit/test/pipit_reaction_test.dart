import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:pipit/pipit.dart';

void main() {
  testWidgets('a hop is reported when the pointer arrives, a squash on tap', (tester) async {
    final reactions = <PipitReaction>[];
    await tester.pumpWidget(
      MaterialApp(
        home: PipitStage(
          builder: (context, seconds) => Center(
            child: PipitView(
              id: 'a',
              look: PipitLook.fromBody(
                PipitPalette.light.bodies.first,
                palette: PipitPalette.light,
              ),
              semanticLabel: 'a',
              seconds: seconds,
              size: 120,
              onTap: () {},
              onReaction: reactions.add,
            ),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(tester.getCenter(find.byType(PipitView)));
    await tester.pump();
    expect(reactions, [PipitReaction.hop]);

    await tester.tap(find.byType(PipitView));
    await tester.pump();
    expect(reactions, [PipitReaction.hop, PipitReaction.squash]);
  });

  testWidgets('a bird without onTap still reports its hop', (tester) async {
    final reactions = <PipitReaction>[];
    await tester.pumpWidget(
      MaterialApp(
        home: PipitStage(
          builder: (context, seconds) => Center(
            child: PipitView(
              id: 'b',
              look: PipitLook.fromBody(
                PipitPalette.light.bodies.first,
                palette: PipitPalette.light,
              ),
              semanticLabel: 'b',
              seconds: seconds,
              size: 120,
              onReaction: reactions.add,
            ),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(PipitView)));
    await tester.pump();
    expect(reactions, [PipitReaction.hop]);
  });
}
