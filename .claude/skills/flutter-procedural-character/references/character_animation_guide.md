# Character Animation Guide

One clock for the screen, per-character phases, poses as springs, and tests that do not depend on
wall time.

---

## 1. The Shared Driver

The screen owns one `Ticker` and publishes seconds. Painters listen through `repaint:`, so a frame
repaints the canvas and rebuilds no widget.

```dart
class const MascotStage({
  super.key,
  required final Widget Function(BuildContext, ValueListenable<double> seconds) builder,
}) extends StatefulWidget {
  @override
  State<MascotStage> createState() => _MascotStageState();
}

class _MascotStageState extends State<MascotStage> with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _seconds = ValueNotifier(0);
  late final Ticker _ticker = createTicker((elapsed) {
    _seconds.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  });

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _seconds);
}
```

`createTicker` from the mixin is muted by `TickerMode`, so the driver stops under a hidden tab or a
covered route. Freeze it under reduced motion instead of starting it:
`if (!MediaQuery.disableAnimationsOf(context)) _ticker.start();` (from `didChangeDependencies`).

## 2. Desynchronised Idle

Derive a stable seed from the character's id (not `String.hashCode`, which is not guaranteed stable
across runs; use a small FNV-1a over the code units). Everything random comes from that seed, and
the per-character constants are computed once, not per frame.

```dart
int stableSeed(String id) {
  var hash = 0x811c9dc5;
  for (final unit in id.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return hash;
}

class IdleMotion(String id) {
  final math.Random _random = math.Random(stableSeed(id));
  late final double phase;
  late final double breathRate;

  this {
    phase = _random.nextDouble() * 2 * math.pi;
    breathRate = 1.6 + _random.nextDouble() * 0.6; // radians per second, never equal
  }

  double breath(double t) => math.sin(t * breathRate + phase); // -1..1
}
```

## 3. Blink Scheduler

A blink is a short closing once per fixed slot, at a jittered point inside it. Computed from time
in O(1) and without allocating, because it runs for every character on every frame.

```dart
const double _slot = 4;     // one blink every 4 s on average
const double _blink = 0.14; // seconds the eyes take to close and open

double eyeOpenness(double t, int seed, double phase) {
  final shifted = t + phase;                          // per-character offset
  final slot = (shifted / _slot).floor();
  final start = slot * _slot + unit01(seed, slot) * (_slot - _blink);
  final k = (shifted - start) / _blink;               // 0..1 through the blink
  if (k < 0 || k > 1) return 1;
  return math.max(0.08, 1 - math.sin(k * math.pi));   // never a flat line
}

/// 0..1 from a seed and an index: an integer hash, no `Random` allocation.
double unit01(int seed, int n) {
  var x = (seed ^ (n * 0x9e3779b1)) & 0xffffffff;
  x = ((x ^ (x >> 16)) * 0x85ebca6b) & 0xffffffff;
  x = ((x ^ (x >> 13)) * 0xc2b2ae35) & 0xffffffff;
  return (x ^ (x >> 16)) / 0xffffffff;
}
```

Never walk blinks from zero in a loop or create a `Random` per frame: both grow with the session
length and the number of characters.

Give each character its own slot length (for example 3.4–5 s from its seed), not one shared
constant: with a shared slot, two characters whose phases happen to be close blink together for
as long as the screen is open. The same holds for breathing: two random rates can land almost
equal, so let each character's tempo wander slowly (a low-frequency sine on the phase, its own
rate and offset per character) and pairs that start in step drift apart within a minute. Test
it over a flock of 20 for several minutes; short windows only measure luck.

## 4. Poses as Springs

A pose is a flat set of doubles with `lerp`. A change of pose sets a target; a critically damped
spring moves the current values toward it every frame, so an interruption continues from wherever
the character is, without a jump.

```dart
class const MascotPose({
  final double bodyTilt = 0,
  final double wingAngle = 0,
  final double squash = 0,
  final double lift = 0,
}) {
  static MascotPose lerp(MascotPose a, MascotPose b, double t) => MascotPose(
    bodyTilt: lerpDouble(a.bodyTilt, b.bodyTilt, t)!,
    wingAngle: lerpDouble(a.wingAngle, b.wingAngle, t)!,
    squash: lerpDouble(a.squash, b.squash, t)!,
    lift: lerpDouble(a.lift, b.lift, t)!,
  );
}
```

Per frame: `current = MascotPose.lerp(current, target, 1 - math.exp(-stiffness * dt))`. That is
frame-rate independent and needs no `AnimationController`.

## 5. Reactions

Hover, tap and "working" are short impulses layered on top of the pose: a hop is
`lift = sin(π·k)` over 0.35 s, a flap is a fast `wingAngle` oscillation while the impulse lasts, a
squash on tap is `squash = 0.12·(1 − k)`. Keep impulses in the stage (not in the painter) with their
start time, and pass the resulting pose in.

## 6. Tests

- **Painter purity:** paint the same look, pose and time twice into a `PictureRecorder` and compare
  the images, or use goldens at fixed `seconds` values (0, blink midpoint, hop peak).
- **Driver:** `await tester.pump(const Duration(milliseconds: 500))` advances the ticker; assert on
  the listenable's value, not on sleeps.
- **Hidden screens:** wrap the stage in `TickerMode(enabled: false)` and assert the value stops.
- **Reduced motion:** `MediaQuery(data: MediaQueryData(disableAnimations: true))` keeps the rest
  pose.

## 7. Measuring

Only profile mode tells the truth (`flutter run --profile`). Read the raster and UI thread times in
DevTools or `FrameTiming` (`SchedulerBinding.instance.addTimingsCallback`). Debug mode is several
times slower and is never the number to report.
