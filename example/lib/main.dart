import 'package:flutter/material.dart';

import 'package:dash_bird/dash_bird.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'dash_bird',
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
  DashPose _pose = DashPose.standing;
  DashAccessory _accessory = DashAccessory.crown;
  DashFacing _facing = DashFacing.front;
  double _mood = 0;

  @override
  Widget build(BuildContext context) {
    final palette = DashPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('dash_bird')),
      // One stage is one clock: every bird below it reads the same seconds.
      body: DashStage(
        builder: (context, seconds) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: DashView(
                id: 'hero',
                look: DashLook.fromBody(palette.bodies.first, palette: palette),
                semanticLabel: 'Dash, ${_pose.name}',
                seconds: seconds,
                size: 180,
                pose: _pose,
                accessory: _accessory,
                facing: _facing,
                expression: DashExpression(mood: _mood),
                onTap: () => setState(() => _mood = _mood > 0 ? -1 : 1),
              ),
            ),
            _Choice(DashPose.values, _pose, (v) => setState(() => _pose = v)),
            _Choice(DashAccessory.values, _accessory, (v) => setState(() => _accessory = v)),
            _Choice(DashFacing.values, _facing, (v) => setState(() => _facing = v)),
            const Divider(height: 32),
            // Each bird's colour and rhythm come from its id.
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < 24; i++)
                  DashView(
                    id: 'bird-$i',
                    look: DashLook.of('bird-$i', palette: palette),
                    semanticLabel: 'Bird $i',
                    seconds: seconds,
                    size: 72,
                    accessory: DashAccessory.values[i % DashAccessory.values.length],
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
