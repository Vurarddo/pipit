import 'package:flutter/material.dart';

import 'package:pipit/pipit.dart';
import 'package:pipit_sounds/pipit_sounds.dart';

void main() => runApp(const ExampleApp());

class const ExampleApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'pipit_sounds',
    theme: ThemeData(colorSchemeSeed: Colors.teal),
    darkTheme: ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
    home: const ExamplePage(),
  );
}

class const ExamplePage({super.key}) extends StatefulWidget {
  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // One player for the bird and the audition chips below it.
  final PipitSoundPlayer _sounds = PipitSoundPlayer();
  PipitPose _pose = PipitPose.standing;

  @override
  void dispose() {
    _sounds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PipitPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('pipit_sounds')),
      body: PipitStage(
        builder: (context, seconds) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Hover for a hop, tap for a squash, pick a pose to hear it.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              // PipitVoice plays each pose as it is entered and voices the reactions.
              child: PipitVoice(
                pose: _pose,
                player: _sounds,
                builder: (context, onReaction) => PipitView(
                  id: 'singer',
                  look: PipitLook.fromBody(palette.bodies[2], palette: palette),
                  semanticLabel: 'Pipit, ${_pose.name}',
                  seconds: seconds,
                  size: 180,
                  pose: _pose,
                  accessory: PipitAccessory.whistle,
                  onTap: () {},
                  onReaction: onReaction,
                ),
              ),
            ),
            _PoseChoice(_pose, (pose) => setState(() => _pose = pose)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final sound in PipitSound.values)
                  ActionChip(
                    label: Text(sound.loops ? '${sound.name} (loop)' : sound.name),
                    onPressed: () => sound.loops ? _sounds.loop(sound) : _sounds.play(sound),
                  ),
                ActionChip(label: const Text('stop loop'), onPressed: _sounds.stopLoop),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class const _PoseChoice(final PipitPose _value, final ValueChanged<PipitPose> _onChanged)
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Wrap(
      spacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final pose in PipitPose.values)
          ChoiceChip(
            label: Text(pose.name),
            selected: pose == _value,
            onSelected: (_) => _onChanged(pose),
          ),
      ],
    ),
  );
}
