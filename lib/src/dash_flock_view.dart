import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_flock.dart';
import 'package:dash_bird/src/dash_flock_bird.dart';
import 'package:dash_bird/src/dash_flock_focus.dart';
import 'package:dash_bird/src/dash_flock_motion.dart';
import 'package:dash_bird/src/dash_flock_painter.dart';

/// A whole flock in one canvas, seen through [camera]; [onBirdTap] gets the
/// index of the bird under a tap; [motion] moves the birds around their
/// positions (hit tests use the positions); [focus] fades all but some birds
/// and links them; [onBirdHover] gets the bird under the pointer (or `null`)
/// and where the pointer is. Birds are drawn by `DashFlockPainter`, so
/// hundreds cost what a few dozen widgets would.
class const DashFlockView({
  super.key,
  required final List<DashFlockBird> birds,
  required final ValueListenable<double> seconds,
  required final ValueListenable<DashCamera> camera,
  required final String semanticLabel,
  final ValueChanged<int>? onBirdTap,
  final DashFlockMotion? motion,
  final ValueListenable<DashFlockFocus?>? focus,
  final void Function(int? index, Offset pointer)? onBirdHover,
}) extends StatefulWidget {
  @override
  State<DashFlockView> createState() => _DashFlockViewState();
}

class _DashFlockViewState extends State<DashFlockView> {
  final DashFlock _flock = DashFlock();
  int? _hovered;

  @override
  void initState() {
    super.initState();
    _flock
      ..birds = widget.birds
      ..motion = widget.motion;
  }

  @override
  void didUpdateWidget(DashFlockView old) {
    super.didUpdateWidget(old);
    _flock
      ..birds = widget.birds
      ..motion = widget.motion;
  }

  @override
  void dispose() {
    _flock.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails details) {
    final index = _flock.birdAt(widget.camera.value.toScene(details.localPosition));
    if (index != null) widget.onBirdTap?.call(index);
  }

  void _onHover(Offset pointer) {
    final index = _flock.birdAt(widget.camera.value.toScene(pointer));
    widget.onBirdHover?.call(index, pointer);
    if (index != _hovered) setState(() => _hovered = index);
  }

  void _onExit() {
    widget.onBirdHover?.call(null, Offset.zero);
    if (_hovered != null) setState(() => _hovered = null);
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onBirdTap != null;
    return Semantics(
      label: widget.semanticLabel,
      child: MouseRegion(
        opaque: false,
        cursor: _hovered != null && tappable ? SystemMouseCursors.click : MouseCursor.defer,
        onHover: widget.onBirdHover == null && !tappable ? null : (e) => _onHover(e.localPosition),
        onExit: (_) => _onExit(),
        child: GestureDetector(
          onTapUp: tappable ? _onTapUp : null,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: DashFlockPainter(
                flock: _flock,
                seconds: widget.seconds,
                camera: widget.camera,
                focus: widget.focus,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
