import 'package:flutter/widgets.dart';

import 'package:pipit/pipit.dart';

import 'package:pipit_sounds/src/pipit_sound.dart';
import 'package:pipit_sounds/src/pipit_sound_player.dart';

/// Builds the bird and receives the callback to pass as `PipitView.onReaction`.
typedef PipitVoiceBuilder = Widget Function(
  BuildContext context,
  ValueChanged<PipitReaction> onReaction,
);

/// Gives one bird a voice. Every change of [pose] plays that pose's sound, a
/// looping pose keeps sounding until the next one, and [builder] receives the
/// `onReaction` that voices hops and squashes. A bird that starts in a looping
/// pose (asleep, flying) starts sounding; one that starts still stays quiet.
/// Silent under reduced motion and while its `TickerMode` is off, like the
/// bird itself.
///
/// ```dart
/// PipitVoice(
///   pose: pose,
///   builder: (context, onReaction) => PipitView(pose: pose, onReaction: onReaction, ...),
/// )
/// ```
///
/// Pass a shared [player] to voice several birds through one set of voices;
/// without it the widget owns a [PipitSoundPlayer] and disposes it.
class const PipitVoice({
  super.key,
  required final PipitPose pose,
  required final PipitVoiceBuilder builder,
  final PipitSoundPlayer? player,
  final double volume = 1,
}) extends StatefulWidget {
  @override
  State<PipitVoice> createState() => _PipitVoiceState();
}

class _PipitVoiceState extends State<PipitVoice> {
  late final PipitSoundPlayer _player = widget.player ?? PipitSoundPlayer(volume: widget.volume);
  bool _muted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final muted = MediaQuery.disableAnimationsOf(context) || !TickerMode.valuesOf(context).enabled;
    if (muted == _muted) return;
    _muted = muted;
    if (muted) {
      _player.stopLoop();
    } else if (PipitSound.ofPose(widget.pose).loops) {
      _player.loop(PipitSound.ofPose(widget.pose));
    }
  }

  @override
  void initState() {
    super.initState();
    // Dependencies are not readable yet; the first didChangeDependencies
    // starts a looping pose when the bird is allowed to sound.
    _muted = true;
  }

  @override
  void didUpdateWidget(PipitVoice old) {
    super.didUpdateWidget(old);
    if (old.pose != widget.pose && !_muted) _player.pose(widget.pose);
  }

  @override
  void dispose() {
    if (widget.player == null) {
      _player.dispose();
    } else {
      _player.stopLoop();
    }
    super.dispose();
  }

  void _onReaction(PipitReaction reaction) {
    if (_muted) return;
    _player.play(PipitSound.ofReaction(reaction));
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _onReaction);
}
