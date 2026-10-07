import 'dart:math';
import 'dart:ui';

/// Where a flock is seen from: a scene point [offset] sits at the view's
/// top-left corner, and one scene unit is [zoom] pixels.
class const DashCamera({final Offset offset = Offset.zero, final double zoom = 1}) {
  static const double minZoom = 0.05;
  static const double maxZoom = 8;

  /// The widest view of [scene] that leaves no more than [margin] pixels of
  /// empty space at any edge: the scene fills [view] along the tighter axis
  /// (with [margin] on both sides) and may run past it along the other,
  /// centred. This is the lowest zoom a camera keeps.
  static DashCamera covering(Rect scene, Size view, {double margin = 20}) {
    final zoom = max(
      (view.width - 2 * margin) / max(scene.width, 1),
      (view.height - 2 * margin) / max(scene.height, 1),
    ).clamp(minZoom, maxZoom);
    return DashCamera(offset: scene.center - view.center(Offset.zero) / zoom, zoom: zoom);
  }

  /// A flight between two cameras over the same [view]: the view's centre
  /// moves in a straight line in scene units, the zoom changes by equal
  /// ratios (so zooming from 0.1 to 1 does not rush through the far half).
  static DashCamera lerp(DashCamera a, DashCamera b, double t, Size view) {
    final zoom = a.zoom * pow(b.zoom / a.zoom, t);
    final centre = Offset.lerp(a.centreOf(view), b.centreOf(view), t)!;
    return DashCamera(offset: centre - view.center(Offset.zero) / zoom, zoom: zoom);
  }

  /// The same camera moved as little as needed to keep [scene] on screen:
  /// no more than [margin] pixels of empty space past any edge, and a scene
  /// smaller than [view] on an axis stays centred on it.
  DashCamera keptOn(Rect scene, Size view, {double margin = 20}) {
    double axis(double offset, double start, double end, double extent) {
      final visible = extent / zoom, pad = margin / zoom;
      if (end - start + 2 * pad <= visible) return (start + end) / 2 - visible / 2;
      return offset.clamp(start - pad, end + pad - visible);
    }

    return DashCamera(
      offset: Offset(
        axis(offset.dx, scene.left, scene.right, view.width),
        axis(offset.dy, scene.top, scene.bottom, view.height),
      ),
      zoom: zoom,
    );
  }

  Offset toScreen(Offset scene) => (scene - offset) * zoom;

  Offset toScene(Offset screen) => screen / zoom + offset;

  /// The scene point in the middle of a [view].
  Offset centreOf(Size view) => toScene(view.center(Offset.zero));

  /// The same camera with [scene] in the middle of [view], at [zoom] if given.
  DashCamera centredOn(Offset scene, Size view, {double? zoom}) {
    final next = (zoom ?? this.zoom).clamp(minZoom, maxZoom);
    return DashCamera(offset: scene - view.center(Offset.zero) / next, zoom: next);
  }

  /// The same camera zoomed by [factor] around the screen point [focus], so
  /// what is under the pointer stays under it. [floor] raises the lowest zoom.
  DashCamera zoomedAt(Offset focus, double factor, {double floor = minZoom}) {
    final next = (zoom * factor).clamp(max<double>(floor, minZoom), maxZoom);
    final anchor = toScene(focus);
    return DashCamera(offset: anchor - focus / next, zoom: next);
  }

  DashCamera panned(Offset screenDelta) =>
      DashCamera(offset: offset - screenDelta / zoom, zoom: zoom);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DashCamera && other.offset == offset && other.zoom == zoom;

  @override
  int get hashCode => Object.hash(offset, zoom);
}
