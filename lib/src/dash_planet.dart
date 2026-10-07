import 'dart:typed_data';
import 'dart:ui';

/// How a bird dot on the planet is marked.
enum DashPlanetMark { none, lead, working }

/// A dotted planet as plain values: [lattice] is x, y, z per point on the
/// unit sphere (y up); [land] the index into [landColors] of each point's
/// continent, or -1 for sea. Bird `birdIds[i]` stands on lattice point `birdPoints[i]` in `birdColors[i]`.
class const DashPlanet({
  required final Float32List lattice,
  required final Int16List land,
  required final List<Color> landColors,
  required final List<String> birdIds,
  required final Int32List birdPoints,
  required final List<Color> birdColors,
  required final List<DashPlanetMark> birdMarks,
}) {
  int get points => land.length;
}
