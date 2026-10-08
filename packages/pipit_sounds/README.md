# pipit_sounds

Sounds for the [pipit](https://pub.dev/packages/pipit) bird: a chirp for
every pose, a hop and a squash, all synthesised to match its motion. Loops
(walking, flying, sleeping, working) are cut to whole wing beats, strides,
breaths and pecks, so they stay in step with the animation.

Playback uses [audioplayers](https://pub.dev/packages/audioplayers); `pipit`
itself stays free of assets and dependencies.

## Install

```yaml
dependencies:
  pipit: ^0.2.0
  pipit_sounds: ^0.1.0
```

## Wire it up

Wrap the bird in a `PipitVoice`: every change of `pose` plays that pose's
sound (a looping pose keeps sounding until the next one), and the `onReaction`
it hands you voices hops and squashes.

```dart
import 'package:pipit/pipit.dart';
import 'package:pipit_sounds/pipit_sounds.dart';

PipitVoice(
  pose: pose,
  builder: (context, onReaction) => PipitView(
    id: 'robin',
    look: PipitLook.of('robin', palette: PipitPalette.of(context)),
    semanticLabel: 'Robin the bird',
    seconds: seconds,
    pose: pose,
    onTap: () {},
    onReaction: onReaction,
  ),
)
```

It is silent under reduced motion and while its `TickerMode` is off, like the
bird. Several birds can share one `PipitSoundPlayer` through the `player`
parameter.

To drive sounds yourself, use the pieces directly:

```dart
final sounds = PipitSoundPlayer(); // dispose it with the screen
sounds.play(PipitSound.hop);
sounds.pose(PipitPose.flying);     // loops until the next pose
```

`PipitSound` is an enum with `ofPose`, `ofReaction`, `loops` and `assetKey`,
so the files work with any other player as well.

## The sounds

| Sound | Plays | Length |
| :--- | :--- | :--- |
| `hop` | a rising chirp with a flutter in it | 0.16 s |
| `squash` | a falling peep over a soft thud | 0.13 s |
| `standing` | two quick notes, the second higher | 0.25 s |
| `sitting` | a slow settling note and a rustle | 0.30 s |
| `alert` | two sharp high tweets | 0.20 s |
| `walking` | two steps, one stride (loop) | 0.90 s |
| `flying` | four wing beats (loop) | 1.14 s |
| `sleeping` | one breath in, one out (loop) | 2.55 s |
| `working` | three pecks and a pause (loop) | 0.90 s |

They are synthesised, not recorded: every one is a function of time and a fixed
seed, so the set is one family. The generator script lives outside the package.

## Example

```sh
cd example
flutter run -d chrome
```

## License

MIT, see [LICENSE](LICENSE).
