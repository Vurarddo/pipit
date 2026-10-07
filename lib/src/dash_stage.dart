import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// The one clock of a screen with birds: every bird below reads [seconds]
/// through its painter's `repaint`, so a frame rebuilds no widget. The stage
/// also shares where the pointer is, so every bird can look at it.
///
/// The ticker comes from this widget's `vsync`, so `TickerMode` (a hidden tab,
/// a covered route) stops it; reduced motion keeps the birds at rest.
class const DashStage({
  super.key,
  required final Widget Function(BuildContext context, ValueListenable<double> seconds) builder,
}) extends StatefulWidget {
  /// The pointer over the nearest stage, in global coordinates, or `null`
  /// when it is elsewhere (or there is no stage).
  static ValueListenable<Offset?>? pointerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DashStageScope>()?.pointer;

  @override
  State<DashStage> createState() => _DashStageState();
}

class _DashStageState extends State<DashStage> with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _seconds = ValueNotifier(0);
  final ValueNotifier<Offset?> _pointer = ValueNotifier(null);
  late final Ticker _ticker = createTicker(
    (elapsed) => _seconds.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _ticker.isActive) _ticker.stop();
    if (!still && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DashStageScope(
    pointer: _pointer,
    child: MouseRegion(
      opaque: false,
      onHover: (event) => _pointer.value = event.position,
      onExit: (_) => _pointer.value = null,
      child: widget.builder(context, _seconds),
    ),
  );
}

class const _DashStageScope({required final ValueListenable<Offset?> pointer, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_DashStageScope old) => old.pointer != pointer;
}
