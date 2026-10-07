/// FNV-1a, 32-bit: a short, stable fingerprint for keys that must not change
/// between app runs (`String.hashCode` may). Not for security.
abstract final class StableHash {
  static String fnv1a(String input) => seed(input).toRadixString(16).padLeft(8, '0');

  /// The same FNV-1a as an integer, for seeding things that must look the
  /// same on every run and machine (a bird's rhythm, its colour).
  static int seed(String input) {
    var hash = 0x811C9DC5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// A number in 0..1 from [seed] and [n], without allocating a `Random`
  /// (called for every bird on every frame).
  static double unit(int seed, int n) {
    var x = (seed ^ (n * 0x9E3779B1)) & 0xFFFFFFFF;
    x = ((x ^ (x >> 16)) * 0x85EBCA6B) & 0xFFFFFFFF;
    x = ((x ^ (x >> 13)) * 0xC2B2AE35) & 0xFFFFFFFF;
    x = x ^ (x >> 16);
    return x / 0xFFFFFFFF;
  }
}
