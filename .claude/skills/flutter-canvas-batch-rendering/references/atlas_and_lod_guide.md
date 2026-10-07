# Sprite Sheets, drawRawAtlas and Levels of Detail

---

## 1. Sprites from Pictures

Draw each distinct object once into a `PictureRecorder` at the sprite size, and pack the results
side by side into one sheet. `toImageSync` needs no `await`, so the painter can build lazily.

```dart
class SpriteSheet(final double cell) {
  final Map<String, int> _slot = {};
  ui.Image? _image;

  ui.Image get image => _image!;

  /// The sprite's source rect in the sheet; [paint] draws the object into a
  /// cell-sized square the first time [key] is seen.
  Rect rectFor(String key, void Function(Canvas canvas, double cell) paint) {
    final index = _slot[key] ??= _add(key, paint);
    return Rect.fromLTWH(index * cell, 0, cell, cell);
  }

  final List<void Function(Canvas, double)> _painters = [];

  int _add(String key, void Function(Canvas, double) paint) {
    _painters.add(paint);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (final (i, p) in _painters.indexed) {
      canvas.save();
      canvas.translate(i * cell, 0);
      p(canvas, cell);
      canvas.restore();
    }
    _image?.dispose();
    _image = recorder.endRecording().toImageSync((cell * _painters.length).ceil(), cell.ceil());
    return _painters.length - 1;
  }
}
```

A sheet grows by one cell per new key; with tens of keys that stays far below texture limits. For
hundreds, wrap into rows.

## 2. One Call for Every Sprite

```dart
// Reused between frames; grown only when the count grows.
var transforms = Float32List(0);
var rects = Float32List(0);

void drawSprites(Canvas canvas, SpriteSheet sheet, List<Placed> items) {
  if (transforms.length < items.length * 4) {
    transforms = Float32List(items.length * 4);
    rects = Float32List(items.length * 4);
  }
  for (final (i, it) in items.indexed) {
    final src = it.src;
    final scale = it.size / sheet.cell;
    transforms
      ..[i * 4] = scale // RSTransform: scos, ssin, tx, ty
      ..[i * 4 + 1] = 0
      ..[i * 4 + 2] = it.center.dx - scale * src.width / 2
      ..[i * 4 + 3] = it.center.dy - scale * src.height / 2;
    rects
      ..[i * 4] = src.left
      ..[i * 4 + 1] = src.top
      ..[i * 4 + 2] = src.right
      ..[i * 4 + 3] = src.bottom;
  }
  canvas.drawRawAtlas(
    sheet.image,
    Float32List.sublistView(transforms, 0, items.length * 4),
    Float32List.sublistView(rects, 0, items.length * 4),
    null,
    null,
    null,
    Paint()..filterQuality = FilterQuality.low,
  );
}
```

`sublistView` does not copy. Keep the `Paint` on the painter.

## 3. Dots in One Call

Put a white disc in the sheet and pass one colour per dot with `BlendMode.modulate`: the white
takes each dot's colour.

```dart
canvas.drawRawAtlas(sheet.image, transforms, rects, colors /* Int32List of ARGB */, BlendMode.modulate, null, paint);
```

## 4. Choosing the Level

```dart
enum Level { live, sprite, dot, hidden }

Level levelFor(double pixels, {double live = 56, double sprite = 14}) =>
    pixels >= live ? Level.live : pixels >= sprite ? Level.sprite : Level.dot;
```

Sort the live candidates by size and let only the first `budget` stay live; the rest become
sprites. The budget comes from the measured live cost: `budget ≈ 12 ms ÷ cost per object`, leaving
room for the rest of the frame.

## 5. What a Sprite Loses

A sprite is a still picture: breathing can be kept as a uniform scale, blinking and wing beats are
lost. That is why the live level exists up close, where they are visible, and why the threshold is
a size on screen.
