import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dash_bird/src/dash_palette.dart';
import 'package:dash_bird/src/dash_planet.dart';
import 'package:dash_bird/src/dash_planet_controller.dart';
import 'package:dash_bird/src/dash_planet_painter.dart';
import 'package:dash_bird/src/dash_terrain.dart';

/// The dotted planet: a drag turns it, [onTap] reports a tap on the globe
/// itself (not on the empty corners around it). [birdsHidden] hides the bird
/// dots while the birds are drawn elsewhere.
class const DashPlanetView({
  super.key,
  required final DashPlanet planet,
  required final DashPlanetController controller,
  required final String semanticLabel,
  final VoidCallback? onTap,
  final ValueListenable<bool>? birdsHidden,
}) extends StatefulWidget {
  /// Where the birds of the planet drawn by the view with [key] are on
  /// screen now (global centre and dot radius, by id); empty when it is not
  /// laid out.
  static Map<String, (Offset, double)> spotsOf(
    GlobalKey key,
    DashPlanet planet,
    DashPlanetController controller,
  ) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return const {};
    return {
      for (final MapEntry(key: id, value: (at, r)) in DashPlanetPainter.birdSpots(
        planet,
        controller.value,
        box.size,
      ).entries)
        id: (box.localToGlobal(at), r),
    };
  }

  @override
  State<DashPlanetView> createState() => _DashPlanetViewState();
}

class _DashPlanetViewState extends State<DashPlanetView> {
  /// Only a tap on the globe counts, not on the empty corners around it.
  void _onTap(TapUpDetails d, Size size) {
    final (c, r) = DashPlanetPainter.frame(size);
    if ((d.localPosition - c).distance <= r) widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final painter = DashPlanetPainter(
      planet: widget.planet,
      colors: DashTerrain.of(context),
      gold: DashPalette.of(context).gold,
      belly: DashPalette.of(context).belly,
      turn: widget.controller,
      birdsHidden: widget.birdsHidden,
    );
    return Semantics(
      label: widget.semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onPanUpdate: (d) => widget.controller.drag(d.delta),
          onTapUp: widget.onTap == null ? null : (d) => _onTap(d, constraints.biggest),
          child: MouseRegion(
            cursor: widget.onTap == null ? SystemMouseCursors.grab : SystemMouseCursors.click,
            child: RepaintBoundary(
              child: CustomPaint(size: Size.infinite, painter: painter),
            ),
          ),
        ),
      ),
    );
  }
}
