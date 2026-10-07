import 'dart:typed_data';

/// Moves a flock's birds around their positions as a function of time: a
/// stroll, a short flight. [offsets] writes dx, dy per bird in scene units
/// (y up is negative) into [out], allocating nothing; the same [seconds]
/// always gives the same offsets.
abstract interface class DashFlockMotion {
  void offsets(double seconds, Float32List out);
}

/// A motion that also resizes birds (a dot growing into a bird in flight):
/// [scales] writes one factor per bird into [out]; 0 hides a bird.
abstract interface class DashFlockScaling implements DashFlockMotion {
  void scales(double seconds, Float32List out);
}

/// A motion that also says which way each bird faces (the way it walks or
/// flies): [facings] writes a `DashFacing` index per bird into [out].
abstract interface class DashFlockFacing implements DashFlockMotion {
  void facings(double seconds, Uint8List out);
}

/// A motion that also poses birds (walking while they stroll, flying in
/// the air): [poses] writes a `DashPose` index per bird into [out], or
/// [ownPose] to keep the bird's own pose (a working bird standing still).
abstract interface class DashFlockPosing implements DashFlockMotion {
  static const int ownPose = 255;

  void poses(double seconds, Uint8List out);
}
