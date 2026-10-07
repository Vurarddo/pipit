/// How much of a bird is drawn, by its size on screen (a live
/// bird costs about 0.05 ms of raster, a sprite about a twentieth of that).
enum DashLevel { live, sprite, dot, hidden }

abstract final class DashLevels {
  /// Live from this many pixels up: blinks and wing beats read from here.
  static const double livePixels = 56;

  /// Sprites down to this many pixels; smaller birds are coloured dots.
  static const double spritePixels = 14;

  /// At most this many live birds a frame, the rest fall back to sprites:
  /// 150 live birds measured at 7.7 ms of raster on the Mac.
  static const int liveBudget = 150;

  static DashLevel of(double pixels) => pixels >= livePixels
      ? DashLevel.live
      : pixels >= spritePixels
      ? DashLevel.sprite
      : DashLevel.dot;
}
