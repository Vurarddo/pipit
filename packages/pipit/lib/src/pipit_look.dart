import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:pipit/src/pipit_palette.dart';
import 'package:pipit/src/stable_hash.dart';

/// The colours of one bird. Build one from a single body colour with
/// [PipitLook.fromBody], let [PipitLook.of] pick a body by the bird's id, or
/// name every colour yourself.
@immutable
class const PipitLook({
  required final Color body,
  required final Color wing,
  required final Color belly,
  required final Color mask,
  required final Color iris,
  required final Color pupil,
  required final Color beak,
  required final Color outline,
  required final Color band,
  required final Color gold,
  required final Color metal,
  required final Color leather,
}) {
  /// A whole look from one [body] colour: wing, mask and outline follow it,
  /// the rest comes from [palette].
  factory PipitLook.fromBody(Color body, {PipitPalette palette = PipitPalette.light}) => PipitLook(
    body: body,
    wing: Color.lerp(body, palette.pupil, 0.22)!,
    belly: palette.belly,
    mask: Color.lerp(body, palette.belly, 0.6)!,
    iris: palette.iris,
    pupil: palette.pupil,
    beak: palette.beak,
    outline: palette.ink ?? Color.lerp(body, palette.pupil, 0.62)!,
    band: Color.lerp(body, palette.pupil, 0.45)!,
    gold: palette.gold,
    metal: palette.metal,
    leather: palette.leather,
  );

  /// The look of the bird called [id]: one of the palette's bodies, always
  /// the same one for the same id, so adding a bird repaints no other.
  factory PipitLook.of(String id, {PipitPalette palette = PipitPalette.light}) =>
      PipitLook.fromBody(
        palette.bodies[StableHash.seed(id) % palette.bodies.length],
        palette: palette,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipitLook &&
          other.body == body &&
          other.wing == wing &&
          other.belly == belly &&
          other.mask == mask &&
          other.iris == iris &&
          other.pupil == pupil &&
          other.beak == beak &&
          other.outline == outline &&
          other.band == band &&
          other.gold == gold &&
          other.metal == metal &&
          other.leather == leather;

  @override
  int get hashCode => Object.hash(
    body,
    wing,
    belly,
    mask,
    iris,
    pupil,
    beak,
    outline,
    band,
    gold,
    metal,
    leather,
  );
}
