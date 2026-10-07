import 'package:flutter/material.dart';

import 'package:pipit/pipit.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'pipit',
    theme: ThemeData(colorSchemeSeed: Colors.blue),
    darkTheme: ThemeData(colorSchemeSeed: Colors.blue, brightness: Brightness.dark),
    home: const ExamplePage(),
  );
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  PipitPose _pose = PipitPose.standing;
  PipitAccessory _accessory = PipitAccessory.crown;
  PipitFacing _facing = PipitFacing.front;
  double _mood = 0;

  @override
  Widget build(BuildContext context) {
    final palette = PipitPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('pipit')),
      // One stage is one clock: every bird below it reads the same seconds.
      body: PipitStage(
        builder: (context, seconds) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: PipitView(
                id: 'hero',
                look: PipitLook.fromBody(palette.bodies.first, palette: palette),
                semanticLabel: 'Pipit, ${_pose.name}',
                seconds: seconds,
                size: 180,
                pose: _pose,
                accessory: _accessory,
                facing: _facing,
                expression: PipitExpression(mood: _mood),
                onTap: () => setState(() => _mood = _mood > 0 ? -1 : 1),
              ),
            ),
            _Choice(PipitPose.values, _pose, (v) => setState(() => _pose = v)),
            _Choice(PipitAccessory.values, _accessory, (v) => setState(() => _accessory = v)),
            _Choice(PipitFacing.values, _facing, (v) => setState(() => _facing = v)),
            const Divider(height: 32),
            // Each bird's colour and rhythm come from its id.
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < 24; i++)
                  PipitView(
                    id: 'bird-$i',
                    look: PipitLook.of('bird-$i', palette: palette),
                    semanticLabel: 'Bird $i',
                    seconds: seconds,
                    size: 72,
                    accessory: PipitAccessory.values[i % PipitAccessory.values.length],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice<T extends Enum> extends StatelessWidget {
  const _Choice(this.values, this.value, this.onChanged);

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Wrap(
      spacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final v in values)
          ChoiceChip(label: Text(v.name), selected: v == value, onSelected: (_) => onChanged(v)),
      ],
    ),
  );
}
