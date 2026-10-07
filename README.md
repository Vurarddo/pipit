# dash_bird

Dash is a small hand-drawn bird for Flutter. It breathes, blinks, looks at the
pointer, hops when the pointer arrives and squashes when tapped. Everything is
drawn on a canvas: no images, no Rive or Lottie files, no dependencies beyond
Flutter.

![Dash in every pose and accessory, on light and dark](https://raw.githubusercontent.com/Vurarddo/dash_bird/main/doc/dash_bird.png)

- Seven poses (`sitting`, `standing`, `walking`, `flying`, `sleeping`,
  `working`, `alert`); a change of pose is a spring from wherever the bird is.
- Four facings (front, left, right, back) and seven accessories (cap, crown,
  headband, helmet, whistle, clock, bag).
- Each bird's rhythm comes from its `id`, so two birds never blink in step and
  the same bird looks the same on every run.
- A flock of thousands is drawn in one canvas: big birds live, smaller ones
  as sprites, the smallest as dots.
- Honours reduced motion and `TickerMode`; every bird has a semantic label.

## Install

```yaml
dependencies:
  dash_bird: ^0.1.0
```

The package needs Dart 3.13 or newer.

## One bird

A `DashStage` is the clock. Every bird below it reads the same `seconds`, and
a frame repaints the birds without rebuilding a widget.

```dart
import 'package:dash_bird/dash_bird.dart';

DashStage(
  builder: (context, seconds) => DashView(
    id: 'robin',
    look: DashLook.of('robin', palette: DashPalette.of(context)),
    semanticLabel: 'Robin the bird',
    seconds: seconds,
    size: 120,
    pose: DashPose.working,
    accessory: DashAccessory.headband,
    onTap: () {},
  ),
)
```

Without `seconds` the bird is a still picture, which is what you want in a
list of hundreds of rows.

### Colours

A `DashLook` is the twelve colours of one bird. You rarely name them all:

```dart
// One body colour; wing, eye mask and outline follow it.
DashLook.fromBody(Colors.teal, palette: DashPalette.of(context));

// A body picked from the palette by the bird's id, always the same one.
DashLook.of('robin', palette: DashPalette.of(context));
```

`DashPalette.of(context)` follows the theme's brightness. To change the shared
colours (belly, beak, eyes, the gold of the crown), add your own palette to
the theme:

```dart
ThemeData(
  extensions: [DashPalette.light.copyWith(belly: const Color(0xFFFFF7E0))],
)
```

### Expression

```dart
DashView(
  // ...
  expression: const DashExpression(
    mood: 1,              // -1 worried, 0 calm, 1 happy
    look: Offset(-1, 0),  // where the eyes point, each axis -1..1
    eyes: DashEyes.open,  // or blinking, closed
  ),
)
```

## A flock

`DashFlockView` draws every bird in one `CustomPaint`. Positions and sizes are
in scene units; a `DashCamera` says which part of the scene is on screen.
Birds that share a `spriteKey` share one sprite when drawn small.

```dart
class _FlockState extends State<Flock> with SingleTickerProviderStateMixin {
  late final DashCameraController _camera = DashCameraController(this);

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = DashPalette.of(context);
    final birds = [
      for (var i = 0; i < 400; i++)
        DashFlockBird(
          id: 'bird-$i',
          position: Offset((i % 25 + 0.5) * 64, (i ~/ 25 + 0.5) * 64),
          size: 56,
          look: DashLook.fromBody(palette.bodies[i % 9], palette: palette),
          spriteKey: 'body-${i % 9}',
        ),
    ];
    return DashCameraGestures(
      controller: _camera,
      scene: const Rect.fromLTWH(0, 0, 1600, 1024),
      child: DashStage(
        builder: (context, seconds) => DashFlockView(
          birds: birds,
          seconds: seconds,
          camera: _camera,
          semanticLabel: 'A flock of 400 birds',
          onBirdTap: (i) => _camera.focus(birds[i].position),
        ),
      ),
    );
  }
}
```

`DashCameraGestures` pans with a drag or trackpad and zooms with the wheel or
a pinch. With keyboard focus, `+` and `-` zoom, `0` shows the whole scene and
the arrows pan.

To move the birds, implement `DashFlockMotion`: it writes an offset per bird
for a given second. `DashFlockScaling`, `DashFlockFacing` and
`DashFlockPosing` add size, direction and pose.

## Scenes

- `DashMeadowView` puts a flock on a meadow of fields, a pond, paths, trees
  and flowers described by a `DashMeadowTerrain`.
- `DashPlanetView` draws a dotted globe you can turn by dragging, with birds
  as dots on its continents.
- `DashFlockFlight` flies a flock from one set of screen positions to another,
  driven by a route's animation.
- `DashWiresPainter` draws wires for the birds to sit on.

Ground colours come from `DashTerrain`, a theme extension like `DashPalette`.

## Example

The [example](example/lib/main.dart) shows one bird with every pose, accessory
and facing, and a flock of 400 with a camera:

```sh
cd example
flutter run -d chrome
```

Only the web platform is checked in; run `flutter create .` in `example` to
add others.

## License

MIT, see [LICENSE](LICENSE).
