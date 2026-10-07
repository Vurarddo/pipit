# Character Geometry Guide

How to describe a character so that one change reshapes it everywhere, and paint it without
allocating per frame.

---

## 1. Coordinates in Units

Put the origin at the body's centre and measure everything in units of the body diameter. The
painter scales the canvas once, so the rest of the code never sees pixels.

```dart
abstract final class MascotProportions {
  static const double bodyRadius = 0.5;   // the body is the unit circle's diameter 1
  static const double bellyWidth = 0.62;  // relative to the body
  static const double eyeSpacing = 0.26;  // centre to centre
  static const double eyeRadius = 0.11;
  static const double footOffsetY = 0.62; // below the centre
}

@override
void paint(Canvas canvas, Size size) {
  final unit = size.shortestSide * 0.8;   // leave room for wings and accessories
  canvas.save();
  canvas.translate(size.width / 2, size.height * 0.55);
  canvas.scale(unit);
  // ... every call below uses unit coordinates
  canvas.restore();
}
```

## 2. Parts, Anchors and Draw Order

Name each part, give it an anchor in units and paint back to front. A part never positions
itself relative to pixels, only to its anchor, so a pose that tilts the body carries the eyes,
beak and accessory with it.

| Order | Part | Anchor (units) | Moves with |
| :-- | :-- | :-- | :-- |
| 1 | Feet | `(±0.14, 0.62)` | ground |
| 2 | Back wing | shoulder | body + wing angle |
| 3 | Body, belly | `(0, 0)` | body tilt, squash |
| 4 | Tuft | `(0, -0.5)` | body |
| 5 | Eyes, beak | face anchor | body + head look |
| 6 | Front wing | shoulder | body + wing angle |
| 7 | Accessory | its part's anchor | that part |

```dart
void paintCharacter(Canvas canvas, MascotLook look, MascotPose pose) {
  _feet.paint(canvas, look, pose);
  canvas.save();
  canvas.rotate(pose.bodyTilt);
  canvas.scale(1 + pose.squash, 1 - pose.squash); // squash keeps volume roughly constant
  _backWing.paint(canvas, look, pose);
  _body.paint(canvas, look, pose);
  _face.paint(canvas, look, pose);
  _frontWing.paint(canvas, look, pose);
  _accessory.paint(canvas, look, pose);
  canvas.restore();
}
```

## 3. Paths Built Once per Look

A look changes rarely (theme switch, accessory change); frames change 60 times a second. Build the
paths when the look changes and keep them.

```dart
class MascotParts(final MascotLook look) {
  final Path tuft = _buildTuft();
  final Path wing = _buildWing();
  final Path beak = _buildBeak();

  static Path _buildWing() => Path()
    ..moveTo(0, 0)
    ..cubicTo(0.18, -0.10, 0.30, 0.10, 0.20, 0.30)
    ..cubicTo(0.10, 0.36, -0.02, 0.20, 0, 0)
    ..close();
  // ...
}
```

Simple shapes (`drawCircle`, `drawOval`) need no cached path at all. A wing flap is a
`canvas.rotate` around the shoulder before `drawPath(parts.wing, …)`, never a new path.

## 4. Paints Owned by the Painter

```dart
class MascotPainter({
  required final ValueListenable<double> frame, // seconds from the shared driver
  required final MascotLook look,
}) extends CustomPainter {
  this : super(repaint: frame);

  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  void _fillWith(Canvas canvas, Path path, Color color) {
    _fill.color = color;         // mutating a field, not allocating
    canvas.drawPath(path, _fill);
  }

  @override
  bool shouldRepaint(MascotPainter old) => old.look != look; // frames come through `repaint`
}
```

The outline width is set in units (for example `0.02`), so it scales with the character.

## 5. Accessories

An accessory is a part with its own anchor on another part (a hat on the tuft anchor, a bag on the
body's side, a band across the forehead). Model the kind as an enum in the kit; the page that shows
the character decides which kind a domain object gets. That keeps domain types out of the kit.

## 6. Views

Front, side and back are separate part sets over the same proportions, not transforms of the
front view. Share proportions, colours and the pose type between them so a pose change reads the
same in every view.
