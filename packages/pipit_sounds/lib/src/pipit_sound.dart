import 'package:pipit/pipit.dart';

/// One sound of the bird's voice. A pose sound plays when the bird enters the
/// pose; the four that [loops] are cut to whole cycles of the bird's motion
/// (wing beats, strides, breaths, pecks) so a host can loop them while the
/// pose lasts. Hop and squash answer the reactions of `PipitView.onReaction`.
enum PipitSound {
  hop,
  squash,
  sitting,
  standing,
  walking,
  flying,
  sleeping,
  working,
  alert;

  /// The sound the bird makes on entering [pose].
  static PipitSound ofPose(PipitPose pose) => switch (pose) {
    PipitPose.sitting => sitting,
    PipitPose.standing => standing,
    PipitPose.walking => walking,
    PipitPose.flying => flying,
    PipitPose.sleeping => sleeping,
    PipitPose.working => working,
    PipitPose.alert => alert,
  };

  /// The sound of a reaction reported by `PipitView.onReaction`.
  static PipitSound ofReaction(PipitReaction reaction) => switch (reaction) {
    PipitReaction.hop => hop,
    PipitReaction.squash => squash,
  };

  /// Whether the file is cut to repeat seamlessly for as long as the pose lasts.
  bool get loops => switch (this) {
    walking || flying || sleeping || working => true,
    hop || squash || sitting || standing || alert => false,
  };

  /// The asset key as a host's bundle sees it, package prefix included, so it
  /// works with any player that reads assets.
  String get assetKey => 'packages/pipit_sounds/assets/sounds/$name.wav';
}
