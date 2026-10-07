import 'package:flutter/material.dart';

/// The colours birds are made of. [bodies] are ready body colours to pick
/// from; everything else is shared by every bird, so a flock reads as one
/// family. Wing, eye mask and outline are derived from the body
/// (`DashLook.fromBody`), so a bird's colours can never clash.
///
/// Add one to `ThemeData.extensions` to restyle every bird below it; without
/// one, [of] follows the theme's brightness.
@immutable
class const DashPalette({
  required final List<Color> bodies,
  required final Color belly,
  required final Color beak,
  required final Color iris,
  required final Color pupil,
  required final Color gold,
  required final Color metal,
  required final Color leather,
  final Color? ink,
}) extends ThemeExtension<DashPalette> {
  static const DashPalette dark = DashPalette(
    bodies: [
      Color(0xFF5AA9FF),
      Color(0xFFA07BFF),
      Color(0xFF2FD4C0),
      Color(0xFF5EE07A),
      Color(0xFFFF8A4C),
      Color(0xFFFF5FA2),
      Color(0xFFFFC53D),
      Color(0xFFB8C0CC),
      Color(0xFF6B7383),
    ],
    belly: Color(0xFFF1F3F8),
    beak: Color(0xFFE8B48F),
    iris: Color(0xFFFF9A5C),
    pupil: Color(0xFF05060A),
    gold: Color(0xFFFFC94D),
    metal: Color(0xFFC3CCDA),
    leather: Color(0xFFB8723F),
  );

  /// On a light ground every bird is outlined in [ink]; on a dark one the
  /// outline is a deep shade of the bird's own body.
  static const DashPalette light = DashPalette(
    bodies: [
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFF0E9F8E),
      Color(0xFF16A34A),
      Color(0xFFEA580C),
      Color(0xFFDB2777),
      Color(0xFFCA8A04),
      Color(0xFF64748B),
      Color(0xFFA3AAB5),
    ],
    belly: Color(0xFFFFFFFF),
    beak: Color(0xFF9A6A4A),
    iris: Color(0xFFE8622C),
    pupil: Color(0xFF0B0D12),
    gold: Color(0xFFD99A00),
    metal: Color(0xFF7D8799),
    leather: Color(0xFF8A4B22),
    ink: Color(0xFF0B0D12),
  );

  /// The theme's palette, or [light] / [dark] by the theme's brightness.
  static DashPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<DashPalette>() ?? (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  DashPalette copyWith({
    List<Color>? bodies,
    Color? belly,
    Color? beak,
    Color? iris,
    Color? pupil,
    Color? gold,
    Color? metal,
    Color? leather,
    Color? ink,
  }) {
    return DashPalette(
      bodies: bodies ?? this.bodies,
      belly: belly ?? this.belly,
      beak: beak ?? this.beak,
      iris: iris ?? this.iris,
      pupil: pupil ?? this.pupil,
      gold: gold ?? this.gold,
      metal: metal ?? this.metal,
      leather: leather ?? this.leather,
      ink: ink ?? this.ink,
    );
  }

  @override
  DashPalette lerp(ThemeExtension<DashPalette>? other, double t) {
    if (other is! DashPalette) return this;
    return DashPalette(
      bodies: bodies.length == other.bodies.length
          ? [for (var i = 0; i < bodies.length; i++) Color.lerp(bodies[i], other.bodies[i], t)!]
          : (t < 0.5 ? bodies : other.bodies),
      belly: Color.lerp(belly, other.belly, t)!,
      beak: Color.lerp(beak, other.beak, t)!,
      iris: Color.lerp(iris, other.iris, t)!,
      pupil: Color.lerp(pupil, other.pupil, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      metal: Color.lerp(metal, other.metal, t)!,
      leather: Color.lerp(leather, other.leather, t)!,
      ink: Color.lerp(ink, other.ink, t),
    );
  }
}
