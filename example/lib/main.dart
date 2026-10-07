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

class _ExamplePageState extends State<ExamplePage> with SingleTickerProviderStateMixin {
  static const Rect _scene = Rect.fromLTWH(0, 0, 1600, 1000);

  late final DashCameraController _camera = DashCameraController(this);
  DashPose _pose = DashPose.standing;
  DashAccessory _accessory = DashAccessory.crown;
  DashFacing _facing = DashFacing.front;
  double _mood = 0;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  /// 400 birds on a grid: far away they are dots, closer sprites, and the
  /// ones big enough to read are drawn live.
  List<DashFlockBird> _flock(DashPalette palette) => [
    for (var i = 0; i < 400; i++)
      DashFlockBird(
        id: 'flock-$i',
        position: Offset((i % 25 + 0.5) * 64, (i ~/ 25 + 0.5) * 62),
        size: 56,
        look: DashLook.fromBody(palette.bodies[i % palette.bodies.length], palette: palette),
        spriteKey: 'body-${i % palette.bodies.length}',
        pose: i % 7 == 0 ? DashPose.sleeping : DashPose.standing,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = DashPalette.of(context);
    final birds = _flock(palette);
    return Scaffold(
      appBar: AppBar(title: const Text('dash_bird')),
      // One stage is one clock: every bird below it reads the same seconds.
      body: DashStage(
        builder: (context, seconds) => Column(
          children: [
            const SizedBox(height: 16),
            DashView(
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
            _Choice(DashPose.values, _pose, (v) => setState(() => _pose = v)),
            _Choice(DashAccessory.values, _accessory, (v) => setState(() => _accessory = v)),
            _Choice(DashFacing.values, _facing, (v) => setState(() => _facing = v)),
            const Divider(height: 24),
            Expanded(
              child: ClipRect(
                child: DashCameraGestures(
                  controller: _camera,
                  scene: _scene,
                  child: DashFlockView(
                    birds: birds,
                    seconds: seconds,
                    camera: _camera,
                    semanticLabel: 'A flock of ${birds.length} birds',
                    onBirdTap: (i) => _camera.focus(birds[i].position, zoom: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _camera.fitAll,
        tooltip: 'Show the whole flock',
        child: const Icon(Icons.zoom_out_map),
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
