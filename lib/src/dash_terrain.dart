import 'package:flutter/material.dart';

/// Colours of the ground the birds live on: the meadow's grass, trees, pond
/// and paths, and the dotted planet's atmosphere and marks. [fieldPeak] is a
/// field's opacity at its middle, [haze] the atmosphere's opacity over the
/// globe. Bird colours stay in `DashPalette`.
///
/// Add one to `ThemeData.extensions` to restyle the ground; without one,
/// [of] follows the theme's brightness.
@immutable
class const DashTerrain({
  required final Color ground,
  required final Color grass,
  required final Color grassHi,
  required final Color canopy,
  required final Color canopyHi,
  required final Color trunk,
  required final Color bush,
  required final Color pond,
  required final Color pondHi,
  required final Color path,
  required final Color flower,
  required final Color clearing,
  required final Color atmosphere,
  required final Color working,
  required final double fieldPeak,
  required final double haze,
}) extends ThemeExtension<DashTerrain> {
  static const DashTerrain dark = DashTerrain(
    ground: Color(0xFF0C1512),
    grass: Color(0xFF1B3328),
    grassHi: Color(0xFF27473A),
    canopy: Color(0xFF173027),
    canopyHi: Color(0xFF21402F),
    trunk: Color(0xFF3A2E26),
    bush: Color(0xFF1E3A30),
    pond: Color(0xFF0F2238),
    pondHi: Color(0xFF1C3A5C),
    path: Color(0xFF1F2420),
    flower: Color(0xFFFFC94D),
    clearing: Color(0xFF12201A),
    atmosphere: Color(0xFF5AA9FF),
    working: Color(0xFF5EE07A),
    fieldPeak: 0.16,
    haze: 0.12,
  );

  static const DashTerrain light = DashTerrain(
    ground: Color(0xFFE4EEDD),
    grass: Color(0xFFC3DBB5),
    grassHi: Color(0xFFA9CB98),
    canopy: Color(0xFF7FAE72),
    canopyHi: Color(0xFF95C087),
    trunk: Color(0xFF8A6A4C),
    bush: Color(0xFF9CC48C),
    pond: Color(0xFFCFE2F4),
    pondHi: Color(0xFFE4EFFA),
    path: Color(0xFFEDE3D2),
    flower: Color(0xFFE8622C),
    clearing: Color(0xFFEEF4E8),
    atmosphere: Color(0xFF1D4ED8),
    working: Color(0xFF157A3A),
    fieldPeak: 0.2,
    haze: 0.035,
  );

  /// The theme's terrain, or [light] / [dark] by the theme's brightness.
  static DashTerrain of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<DashTerrain>() ?? (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  DashTerrain copyWith({
    Color? ground,
    Color? grass,
    Color? grassHi,
    Color? canopy,
    Color? canopyHi,
    Color? trunk,
    Color? bush,
    Color? pond,
    Color? pondHi,
    Color? path,
    Color? flower,
    Color? clearing,
    Color? atmosphere,
    Color? working,
    double? fieldPeak,
    double? haze,
  }) => DashTerrain(
    ground: ground ?? this.ground,
    grass: grass ?? this.grass,
    grassHi: grassHi ?? this.grassHi,
    canopy: canopy ?? this.canopy,
    canopyHi: canopyHi ?? this.canopyHi,
    trunk: trunk ?? this.trunk,
    bush: bush ?? this.bush,
    pond: pond ?? this.pond,
    pondHi: pondHi ?? this.pondHi,
    path: path ?? this.path,
    flower: flower ?? this.flower,
    clearing: clearing ?? this.clearing,
    atmosphere: atmosphere ?? this.atmosphere,
    working: working ?? this.working,
    fieldPeak: fieldPeak ?? this.fieldPeak,
    haze: haze ?? this.haze,
  );

  @override
  DashTerrain lerp(ThemeExtension<DashTerrain>? other, double t) {
    if (other is! DashTerrain) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DashTerrain(
      ground: mix(ground, other.ground),
      grass: mix(grass, other.grass),
      grassHi: mix(grassHi, other.grassHi),
      canopy: mix(canopy, other.canopy),
      canopyHi: mix(canopyHi, other.canopyHi),
      trunk: mix(trunk, other.trunk),
      bush: mix(bush, other.bush),
      pond: mix(pond, other.pond),
      pondHi: mix(pondHi, other.pondHi),
      path: mix(path, other.path),
      flower: mix(flower, other.flower),
      clearing: mix(clearing, other.clearing),
      atmosphere: mix(atmosphere, other.atmosphere),
      working: mix(working, other.working),
      fieldPeak: fieldPeak + (other.fieldPeak - fieldPeak) * t,
      haze: haze + (other.haze - haze) * t,
    );
  }
}
