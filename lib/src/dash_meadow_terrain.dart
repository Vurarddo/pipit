import 'dart:typed_data';
import 'dart:ui';

/// One tinted field: its outline corners (x, y pairs, drawn smoothed
/// through their midpoints) around [centre], tinted [color] that fades to
/// nothing at the edge.
class const DashMeadowField({
  required final Float64List corners,
  required final Offset centre,
  required final double reach,
  required final Color color,
});

/// The ground a flock stands on, in scene units: fields, the [pond] (an
/// oval), [paths] (x, y pairs each), and x, y, size triples of [trees],
/// [bushes], grass [tufts] and [flowers]. Plain values: what a field means
/// is up to the caller.
class const DashMeadowTerrain({
  required final Size size,
  required final List<DashMeadowField> fields,
  required final Rect pond,
  required final List<Float32List> paths,
  required final Float32List trees,
  required final Float32List bushes,
  required final Float32List tufts,
  required final Float32List flowers,
});
