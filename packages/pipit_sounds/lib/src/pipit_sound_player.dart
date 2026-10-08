import 'package:audioplayers/audioplayers.dart';

import 'package:pipit/pipit.dart';

import 'package:pipit_sounds/src/pipit_sound.dart';

/// Plays [PipitSound]s: short ones over each other, one loop at a time.
/// Create one per screen, give it the bird's reactions and pose changes, and
/// dispose it with the screen.
///
/// ```dart
/// final sounds = PipitSoundPlayer();
/// PipitView(
///   onReaction: (reaction) => sounds.play(PipitSound.ofReaction(reaction)),
///   ...
/// );
/// sounds.pose(PipitPose.flying); // the flap loop, until the next pose
/// ```
class PipitSoundPlayer({final double volume = 1}) {
  // A few one-shot players so a hop over a squash does not cut either off.
  static const int _voices = 4;
  final List<AudioPlayer> _oneShots = [];
  AudioPlayer? _loop;
  int _next = 0;
  bool _disposed = false;

  /// Plays [sound] once over whatever is already playing.
  Future<void> play(PipitSound sound) async {
    if (_disposed) return;
    if (_oneShots.isEmpty) {
      for (var i = 0; i < _voices; i++) {
        _oneShots.add(_player());
      }
    }
    final player = _oneShots[_next];
    _next = (_next + 1) % _voices;
    await player.play(AssetSource(sound.assetKey), volume: volume, mode: PlayerMode.lowLatency);
  }

  /// Loops [sound] until [stopLoop] or the next [loop]; one loop at a time.
  Future<void> loop(PipitSound sound) async {
    if (_disposed) return;
    final player = _loop ??= _player()..setReleaseMode(ReleaseMode.loop);
    await player.stop();
    await player.play(AssetSource(sound.assetKey), volume: volume);
  }

  Future<void> stopLoop() async => _loop?.stop();

  /// Voices a change of pose: a looping pose keeps playing until the next
  /// pose, a one-shot pose plays once and stops whatever looped before.
  Future<void> pose(PipitPose pose) async {
    final sound = PipitSound.ofPose(pose);
    if (sound.loops) return loop(sound);
    await stopLoop();
    await play(sound);
  }

  Future<void> dispose() async {
    _disposed = true;
    await Future.wait([for (final p in _oneShots) p.dispose(), ?_loop?.dispose()]);
    _oneShots.clear();
    _loop = null;
  }

  // The asset keys already carry the package prefix, so the cache adds none.
  AudioPlayer _player() => AudioPlayer()..audioCache = AudioCache(prefix: '');
}
