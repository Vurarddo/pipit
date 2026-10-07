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

Put one stage above all the birds of a screen rather than one per bird.
Without `seconds` a bird is a still picture.

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

## Example

The [example](example/lib/main.dart) shows one bird with every pose, accessory
and facing, and two dozen more, each with its own colour and rhythm:

```sh
cd example
flutter run -d chrome
```

Only the web platform is checked in; run `flutter create .` in `example` to
add others.

## License

MIT, see [LICENSE](LICENSE).
