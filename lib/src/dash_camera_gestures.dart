import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dash_bird/src/dash_camera_controller.dart';

/// Drives a [DashCameraController] by hand: drag or a
/// trackpad pans, the wheel or a pinch zooms around the pointer; with focus,
/// `+` / `-` zoom, `0` shows the whole [scene], arrows pan. The first layout
/// shows the whole scene.
class const DashCameraGestures({
  super.key,
  required final DashCameraController controller,
  required final Rect scene,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<DashCameraGestures> createState() => _DashCameraGesturesState();
}

class _DashCameraGesturesState extends State<DashCameraGestures> {
  static const double _wheelStep = 1.1;
  static const double _keyStep = 1.25;
  static const double _arrowPan = 80;

  final FocusNode _focus = FocusNode(debugLabel: 'dash_camera');
  double _lastScale = 1;
  bool _fitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.still = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// The wheel is claimed here, so a page under the flock does not scroll too.
  void _onSignal(PointerSignalEvent event) {
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      if (event is PointerScrollEvent) {
        widget.controller.zoomAt(
          event.localPosition,
          event.scrollDelta.dy < 0 ? _wheelStep : 1 / _wheelStep,
        );
      }
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    widget.controller.pan(d.focalPointDelta);
    if (d.scale != _lastScale && d.pointerCount != 1) {
      widget.controller.zoomAt(d.localFocalPoint, d.scale / _lastScale);
    }
    _lastScale = d.scale;
  }

  void _layout(Size size) {
    final controller = widget.controller;
    final resized = _fitted && size != controller.viewport;
    controller
      ..viewport = size
      ..scene = widget.scene;
    // A window grown (or shrunk) since: the lowest zoom and the edges move
    // with it, so the camera settles into the new view after this frame.
    if (resized) WidgetsBinding.instance.addPostFrameCallback((_) => controller.settle());
    if (_fitted || size.isEmpty) return;
    _fitted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final still = controller.still;
      controller
        ..still = true
        ..fitAll()
        ..still = still;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.equal): () => c.zoomBy(_keyStep),
        const SingleActivator(LogicalKeyboardKey.equal, shift: true): () => c.zoomBy(_keyStep),
        const SingleActivator(LogicalKeyboardKey.minus): () => c.zoomBy(1 / _keyStep),
        const SingleActivator(LogicalKeyboardKey.digit0): c.fitAll,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            c.pan(const Offset(_arrowPan, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            c.pan(const Offset(-_arrowPan, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => c.pan(const Offset(0, _arrowPan)),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            c.pan(const Offset(0, -_arrowPan)),
      },
      child: Focus(
        focusNode: _focus,
        child: Listener(
          onPointerDown: (_) => _focus.requestFocus(),
          onPointerSignal: _onSignal,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) => _lastScale = 1,
              onScaleUpdate: _onScaleUpdate,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _layout(constraints.biggest);
                  return widget.child;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
