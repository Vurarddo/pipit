import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'package:dash_bird/src/dash_camera.dart';

/// The camera of one flock: pan and zoom follow the hand at
/// once, fit and focus fly there. A hand gesture stops a flight where it is.
/// `DashCameraGestures` keeps [viewport] and [scene] current.
class DashCameraController(
  final TickerProvider _vsync, {
  final DashCamera initial = const DashCamera(),
}) extends ValueNotifier<DashCamera> {
  this : super(initial);

  /// How far past the scene's edge the view may go, in pixels.
  static const double _edge = 20;

  static const Duration _flightTime = Duration(milliseconds: 520);

  Size viewport = Size.zero;
  Rect scene = Rect.zero;

  /// Under reduced motion a fit or focus jumps instead of flying.
  bool still = false;

  late final AnimationController _flight = AnimationController(
    vsync: _vsync,
    duration: _flightTime,
  )..addListener(_fly);
  DashCamera _from = initial;
  DashCamera _to = initial;

  bool get isFlying => _flight.isAnimating;

  /// The camera never goes further out than the scene filling the view.
  double get _floor => scene.isEmpty || viewport.isEmpty
      ? DashCamera.minZoom
      : DashCamera.covering(scene, viewport, margin: _edge).zoom;

  void pan(Offset screenDelta) {
    _flight.stop();
    value = _kept(value.panned(screenDelta));
  }

  void zoomAt(Offset focus, double factor) {
    _flight.stop();
    value = _kept(value.zoomedAt(focus, factor, floor: _floor));
  }

  /// Zoom around the middle of the view (keys, buttons).
  void zoomBy(double factor) => zoomAt(viewport.center(Offset.zero), factor);

  /// Keeps the camera inside the rules after the view changed size: no
  /// lower than the lowest zoom (the scene filling the view), no further
  /// past an edge than [_edge]. A flight in progress keeps its course.
  void settle() {
    if (isFlying || scene.isEmpty || viewport.isEmpty) return;
    final floor = _floor;
    final raised = value.zoom < floor
        ? value.centredOn(value.centreOf(viewport), viewport, zoom: floor)
        : value;
    value = _kept(raised);
  }

  /// The widest view: the whole scene at the lowest zoom.
  void fitAll() {
    if (!scene.isEmpty && !viewport.isEmpty) {
      flyTo(DashCamera.covering(scene, viewport, margin: _edge));
    }
  }

  /// Brings [scenePoint] to the middle, close enough that a bird there is
  /// drawn live ([zoom] if given, never further out than now).
  void focus(Offset scenePoint, {double? zoom}) {
    if (viewport.isEmpty) return;
    final next = zoom ?? (value.zoom < 1 ? 1.0 : value.zoom);
    flyTo(value.centredOn(scenePoint, viewport, zoom: next));
  }

  void flyTo(DashCamera goal) {
    _flight.stop();
    final target = _kept(
      goal.zoom < _floor ? goal.centredOn(goal.centreOf(viewport), viewport, zoom: _floor) : goal,
    );
    if (still || viewport.isEmpty) {
      value = target;
      return;
    }
    _from = value;
    _to = target;
    _flight.forward(from: 0);
  }

  /// Keeps the scene on screen, [_edge] pixels of slack past its edges.
  DashCamera _kept(DashCamera camera) =>
      scene.isEmpty || viewport.isEmpty ? camera : camera.keptOn(scene, viewport, margin: _edge);

  void _fly() {
    final t = Curves.easeInOutCubic.transform(_flight.value);
    value = DashCamera.lerp(_from, _to, t, viewport);
  }

  @override
  void dispose() {
    _flight.dispose();
    super.dispose();
  }
}
