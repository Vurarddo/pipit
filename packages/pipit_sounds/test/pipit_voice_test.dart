import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:pipit/pipit.dart';
import 'package:pipit_sounds/pipit_sounds.dart';

/// Records what would be played; no audio plugin is touched in a test.
class _Recorder extends PipitSoundPlayer {
  final List<String> log = [];

  @override
  Future<void> play(PipitSound sound) async => log.add('play ${sound.name}');

  @override
  Future<void> loop(PipitSound sound) async => log.add('loop ${sound.name}');

  @override
  Future<void> stopLoop() async => log.add('stop');

  @override
  Future<void> pose(PipitPose pose) async => log.add('pose ${pose.name}');

  @override
  Future<void> dispose() async => log.add('dispose');
}

Widget _voice(_Recorder player, PipitPose pose, {bool ticking = true, bool reduced = false}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: TickerMode(
        enabled: ticking,
        child: PipitVoice(
          pose: pose,
          player: player,
          builder: (context, onReaction) => GestureDetector(
            key: const Key('bird'),
            onTap: () => onReaction(PipitReaction.squash),
            onDoubleTap: () => onReaction(PipitReaction.hop),
          ),
        ),
      ),
    );

void main() {
  testWidgets('a still first pose is quiet, a change of pose is voiced', (tester) async {
    final player = _Recorder();
    await tester.pumpWidget(_voice(player, PipitPose.standing));
    expect(player.log, isEmpty);

    await tester.pumpWidget(_voice(player, PipitPose.flying));
    expect(player.log, ['pose flying']);
  });

  testWidgets('a looping first pose starts sounding at once', (tester) async {
    final player = _Recorder();
    await tester.pumpWidget(_voice(player, PipitPose.sleeping));
    expect(player.log, ['loop sleeping']);
  });

  testWidgets('reactions reach the player', (tester) async {
    final player = _Recorder();
    await tester.pumpWidget(_voice(player, PipitPose.standing));
    await tester.tap(find.byKey(const Key('bird')));
    await tester.pump(kDoubleTapTimeout);
    expect(player.log, ['play squash']);
  });

  testWidgets('reduced motion and a stopped ticker mute the bird', (tester) async {
    final player = _Recorder();
    await tester.pumpWidget(_voice(player, PipitPose.sleeping, reduced: true));
    await tester.pumpWidget(_voice(player, PipitPose.flying, reduced: true));
    await tester.tap(find.byKey(const Key('bird')));
    await tester.pump(kDoubleTapTimeout);
    expect(player.log, isEmpty);

    await tester.pumpWidget(_voice(player, PipitPose.flying, ticking: false));
    expect(player.log, isEmpty);

    // Allowed to sound again: the looping pose resumes.
    await tester.pumpWidget(_voice(player, PipitPose.flying));
    expect(player.log, ['loop flying']);
  });

  testWidgets('a shared player is stopped, not disposed, with the widget', (tester) async {
    final player = _Recorder();
    await tester.pumpWidget(_voice(player, PipitPose.walking));
    await tester.pumpWidget(const SizedBox());
    expect(player.log, ['loop walking', 'stop']);
  });
}
