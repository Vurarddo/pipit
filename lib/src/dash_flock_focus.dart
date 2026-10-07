import 'dart:ui';

/// Which birds of a flock stand out: the birds of [lit] keep
/// their colour, the rest fade to [dim]; a line runs from [centre] to every
/// other lit bird. [centre] -1 draws no lines (a gathering names no one).
class const DashFlockFocus({
  required final int centre,
  required final Set<int> lit,
  required final Color line,
  final double dim = 0.22,
}) {
  /// Opaque white or faded white: a colour that `BlendMode.modulate` turns
  /// into the bird's own colour at full or faded strength.
  int tint(int i) => lit.contains(i) ? 0xFFFFFFFF : ((dim * 255).round() << 24) | 0x00FFFFFF;

  /// [color] with bird [i]'s strength.
  int fade(int i, int color) =>
      lit.contains(i) ? color : ((((color >>> 24) * dim).round()) << 24) | (color & 0x00FFFFFF);

  /// The links from the centre, [at] giving a bird's place on screen.
  void paintLinks(Canvas canvas, Paint paint, double zoom, Offset Function(int i) at) {
    if (centre < 0) return;
    paint
      ..color = line
      ..strokeWidth = (1.6 * zoom).clamp(1.0, 2.4);
    final from = at(centre);
    for (final i in lit) {
      if (i != centre) canvas.drawLine(from, at(i), paint);
    }
  }
}
