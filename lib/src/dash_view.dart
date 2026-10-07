import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dash_bird/src/dash_accessory.dart';
import 'package:dash_bird/src/dash_expression.dart';
import 'package:dash_bird/src/dash_facing.dart';
import 'package:dash_bird/src/dash_look.dart';
import 'package:dash_bird/src/dash_motion.dart';
import 'package:dash_bird/src/dash_painter.dart';
import 'package:dash_bird/src/dash_pose.dart';
import 'package:dash_bird/src/dash_pose_transition.dart';
import 'package:dash_bird/src/dash_reactions.dart';
import 'package:dash_bird/src/dash_stage.dart';

/// One living bird. [id] decides its rhythm, so two birds never breathe or
/// blink in step; [seconds] is the clock of the surrounding [DashStage], or
/// `null` for a bird at rest. A new [pose] or [expression] is reached along
/// a spring from wherever the bird is, never by a cut. On a stage the bird
/// looks at the pointer and hops when it arrives; with [onTap] it squashes
/// when tapped.
class const DashView({
  super.key,
  required final String id,
  required final DashLook look,
  required final String semanticLabel,
  final ValueListenable<double>? seconds,
  final double size = 96,
  final DashFacing facing = DashFacing.front,
  final DashAccessory accessory = DashAccessory.none,
  final DashPose pose = DashPose.standing,
  final DashExpression expression = DashExpression.calm,
  final VoidCallback? onTap,
}) extends StatefulWidget {
  @override
  State<DashView> createState() => _DashViewState();
}

class _DashViewState extends State<DashView> {
  late final DashPoseTransition _transition = DashPoseTransition(_target());
  final DashReactions _reactions = DashReactions();
  late DashIdle _idle = DashIdle(widget.id);
  ValueListenable<Offset?>? _pointer;
  Offset _follow = Offset.zero;

  double get _now => widget.seconds?.value ?? double.infinity;

  DashPoseValues _target() => DashPoseValues.of(
    widget.pose,
    DashExpression(
      eyes: widget.expression.eyes,
      look: widget.expression.look + _follow,
      mood: widget.expression.mood,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pointer = DashStage.pointerOf(context);
    if (pointer == _pointer) return;
    _pointer?.removeListener(_onPointer);
    _pointer = pointer?..addListener(_onPointer);
  }

  @override
  void didUpdateWidget(DashView old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _idle = DashIdle(widget.id);
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

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return Semantics(
      label: widget.semanticLabel,
      image: !tappable,
      button: tappable,
      child: MouseRegion(
        cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => _reactions.hop(_now),
        child: GestureDetector(
          onTap: tappable
              ? () {
                  _reactions.squash(_now);
                  widget.onTap!();
                }
              : null,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: DashPainter(
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
