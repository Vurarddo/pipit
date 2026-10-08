import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pipit/src/pipit_accessory.dart';
import 'package:pipit/src/pipit_expression.dart';
import 'package:pipit/src/pipit_facing.dart';
import 'package:pipit/src/pipit_look.dart';
import 'package:pipit/src/pipit_motion.dart';
import 'package:pipit/src/pipit_painter.dart';
import 'package:pipit/src/pipit_pose.dart';
import 'package:pipit/src/pipit_pose_transition.dart';
import 'package:pipit/src/pipit_reactions.dart';
import 'package:pipit/src/pipit_stage.dart';

/// One living bird. [id] decides its rhythm, so two birds never breathe or
/// blink in step; [seconds] is the clock of the surrounding [PipitStage], or
/// `null` for a bird at rest. A new [pose] or [expression] is reached along
/// a spring from wherever the bird is, never by a cut. On a stage the bird
/// looks at the pointer and hops when it arrives; with [onTap] it squashes
/// when tapped. [onReaction] reports each hop and squash as it starts.
class const PipitView({
  super.key,
  required final String id,
  required final PipitLook look,
  required final String semanticLabel,
  final ValueListenable<double>? seconds,
  final double size = 96,
  final PipitFacing facing = PipitFacing.front,
  final PipitAccessory accessory = PipitAccessory.none,
  final PipitPose pose = PipitPose.standing,
  final PipitExpression expression = PipitExpression.calm,
  final VoidCallback? onTap,
  final ValueChanged<PipitReaction>? onReaction,
}) extends StatefulWidget {
  @override
  State<PipitView> createState() => _PipitViewState();
}

class _PipitViewState extends State<PipitView> {
  late final PipitPoseTransition _transition = PipitPoseTransition(_target());
  final PipitReactions _reactions = PipitReactions();
  late PipitIdle _idle = PipitIdle(widget.id);
  ValueListenable<Offset?>? _pointer;
  Offset _follow = Offset.zero;

  double get _now => widget.seconds?.value ?? double.infinity;

  PipitPoseValues _target() => PipitPoseValues.of(
    widget.pose,
    PipitExpression(
      eyes: widget.expression.eyes,
      look: widget.expression.look + _follow,
      mood: widget.expression.mood,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pointer = PipitStage.pointerOf(context);
    if (pointer == _pointer) return;
    _pointer?.removeListener(_onPointer);
    _pointer = pointer?..addListener(_onPointer);
  }

  @override
  void didUpdateWidget(PipitView old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _idle = PipitIdle(widget.id);
    if (old.pose != widget.pose || old.expression != widget.expression) {
      _transition.retarget(_target(), _now);
    }
  }

  @override
  void dispose() {
    _pointer?.removeListener(_onPointer);
    super.dispose();
  }

  /// Eyes follow the pointer across the stage: a pointer one and a half bird
  /// widths away or further is looked at fully, and the bird leans to it.
  void _onPointer() {
    if (widget.seconds == null) return;
    final box = context.findRenderObject();
    final at = _pointer?.value;
    var follow = Offset.zero;
    if (at != null && box is RenderBox && box.attached && box.hasSize) {
      final local = box.globalToLocal(at) - box.size.center(Offset.zero);
      final reach = box.size.width * 1.5;
      follow = Offset((local.dx / reach).clamp(-1, 1), (local.dy / reach).clamp(-1, 1));
    }
    if ((follow - _follow).distance < 0.02) return;
    _follow = follow;
    _transition.retarget(_target(), _now);
  }

  void _react(PipitReaction reaction) {
    switch (reaction) {
      case PipitReaction.hop:
        _reactions.hop(_now);
      case PipitReaction.squash:
        _reactions.squash(_now);
    }
    widget.onReaction?.call(reaction);
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return Semantics(
      label: widget.semanticLabel,
      image: !tappable,
      button: tappable,
      child: MouseRegion(
        cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => _react(PipitReaction.hop),
        child: GestureDetector(
          onTap: tappable
              ? () {
                  _react(PipitReaction.squash);
                  widget.onTap!();
                }
              : null,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: PipitPainter(
                look: widget.look,
                idle: _idle,
                transition: _transition,
                reactions: _reactions,
                seconds: widget.seconds,
                facing: widget.facing,
                accessory: widget.accessory,
                eyes: widget.expression.eyes,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
