# pipit

Pipit is a small hand-drawn bird for Flutter. It breathes, blinks, looks at the
pointer, hops when the pointer arrives and squashes when tapped. Everything is
drawn on a canvas: no images, no Rive or Lottie files, no dependencies beyond
Flutter.

![Pipit in every pose and accessory, on light and dark](https://raw.githubusercontent.com/Vurarddo/pipit/main/packages/pipit/doc/pipit.png)

- Seven poses (`sitting`, `standing`, `walking`, `flying`, `sleeping`,
  `working`, `alert`); a change of pose is a spring from wherever the bird is.
- Four facings (front, left, right, back) and seven accessories (cap, crown,
  headband, helmet, whistle, clock, bag).
- Each bird's rhythm comes from its `id`, so two birds never blink in step and
  the same bird looks the same on every run.
- Honours reduced motion and `TickerMode`; every bird has a semantic label.
- Reports its hops and squashes through `onReaction`; the
  [pipit_sounds](https://pub.dev/packages/pipit_sounds) package gives them a voice.

## Install

```yaml
dependencies:
  pipit: ^0.2.0
```

The package needs Dart 3.13 or newer.

## One bird

A `PipitStage` is the clock. Every bird below it reads the same `seconds`, and
a frame repaints the birds without rebuilding a widget.

```dart
import 'package:pipit/pipit.dart';

PipitStage(
  builder: (context, seconds) => PipitView(
    id: 'robin',
    look: PipitLook.of('robin', palette: PipitPalette.of(context)),
    semanticLabel: 'Robin the bird',
    seconds: seconds,
    size: 120,
    pose: PipitPose.working,
    accessory: PipitAccessory.headband,
    onTap: () {},
    onReaction: (reaction) {}, // a hop when hovered, a squash when tapped; see pipit_sounds
  ),
)
```

Put one stage above all the birds of a screen rather than one per bird.
Without `seconds` a bird is a still picture.

### Colours

A `PipitLook` is the twelve colours of one bird. You rarely name them all:

```dart
// One body colour; wing, eye mask and outline follow it.
PipitLook.fromBody(Colors.teal, palette: PipitPalette.of(context));

// A body picked from the palette by the bird's id, always the same one.
PipitLook.of('robin', palette: PipitPalette.of(context));
```

`PipitPalette.of(context)` follows the theme's brightness. To change the shared
colours (belly, beak, eyes, the gold of the crown), add your own palette to
the theme:

```dart
ThemeData(
  extensions: [PipitPalette.light.copyWith(belly: const Color(0xFFFFF7E0))],
)
```

### Expression

```dart
PipitView(
  // ...
  expression: const PipitExpression(
    mood: 1,              // -1 worried, 0 calm, 1 happy
    look: Offset(-1, 0),  // where the eyes point, each axis -1..1
    eyes: PipitEyes.open,  // or blinking, closed
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
