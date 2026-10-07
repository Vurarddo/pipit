import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:dash_bird/src/dash_camera.dart';
import 'package:dash_bird/src/dash_camera_controller.dart';
import 'package:dash_bird/src/dash_camera_gestures.dart';

const _scene = Rect.fromLTWH(0, 0, 2400, 1200);
const _view = Size(800, 600);

void _near(Offset a, Offset b) {
  expect(a.dx, closeTo(b.dx, 1e-6));
  expect(a.dy, closeTo(b.dy, 1e-6));
}

class _Host extends StatefulWidget {
  const _Host(this.onController);
  final void Function(DashCameraController) onController;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> with SingleTickerProviderStateMixin {
  late final DashCameraController camera = DashCameraController(this);

  @override
  void initState() {
    super.initState();
    widget.onController(camera);
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: DashCameraGestures(
      controller: camera,
      scene: _scene,
      child: const SizedBox.expand(key: ValueKey('camera_area')),
    ),
  );
}

void main() {
  group('DashCamera', () {
    test('covering fills the view along the tighter axis, 20 px from its edges', () {
      final cam = DashCamera.covering(_scene, _view);
      expect(cam.zoom, closeTo(560 / 1200, 1e-9));
      _near(cam.centreOf(_view), _scene.center);
      expect(cam.toScreen(_scene.topLeft).dy, closeTo(20, 1e-6));
    });

    test('a flight keeps its ends, zooms by equal ratios and moves the centre straight', () {
      const a = DashCamera(zoom: 0.1);
      final b = const DashCamera().centredOn(const Offset(500, 300), _view, zoom: 1);
      expect(DashCamera.lerp(a, b, 0, _view), a);
      _near(DashCamera.lerp(a, b, 1, _view).offset, b.offset);
      final mid = DashCamera.lerp(a, b, 0.5, _view);
      expect(mid.zoom, closeTo(0.316227, 1e-5));
      _near(mid.centreOf(_view), (a.centreOf(_view) + b.centreOf(_view)) / 2);
    });

    test('zooming out stops at the floor and keeps the point under the pointer', () {
      const cam = DashCamera(zoom: 0.4);
      final out = cam.zoomedAt(const Offset(100, 100), 0.1, floor: 0.2);
      expect(out.zoom, 0.2);
      _near(out.toScene(const Offset(100, 100)), cam.toScene(const Offset(100, 100)));
    });
  });

  group('DashCameraController and gestures', () {
    late DashCameraController camera;

    Future<void> host(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_view);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_Host((c) => camera = c));
      await tester.pump();
    }

    testWidgets('the first layout shows the whole scene without a flight', (tester) async {
      await host(tester);
      expect(camera.value, DashCamera.covering(_scene, _view));
      expect(camera.isFlying, isFalse);
    });

    testWidgets('focus flies to a point; a drag stops the flight where it is', (tester) async {
      await host(tester);
      camera.focus(const Offset(1200, 600));
      await tester.pump(const Duration(milliseconds: 100));
      expect(camera.isFlying, isTrue);
      await tester.pumpAndSettle();
      _near(camera.value.centreOf(_view), const Offset(1200, 600));
      expect(camera.value.zoom, 1);

      camera.fitAll();
      await tester.pump(const Duration(milliseconds: 100));
      final before = camera.value;
      await tester.drag(find.byKey(const ValueKey('camera_area')), const Offset(-120, 0));
      expect(camera.isFlying, isFalse);
      expect(camera.value.offset.dx, greaterThan(before.offset.dx));
    });

    testWidgets('the wheel zooms around the pointer, never out past the scene filling the view', (
      tester,
    ) async {
      await host(tester);
      final fit = camera.value;
      const pointer = Offset(400, 300);
      final under = fit.toScene(pointer);
      for (var i = 0; i < 3; i++) {
        tester.binding.handlePointerEvent(
          const PointerScrollEvent(position: pointer, scrollDelta: Offset(0, -20)),
        );
      }
      await tester.pump();
      expect(camera.value.zoom, closeTo(fit.zoom * 1.331, 1e-9));
      _near(camera.value.toScene(pointer), under);
      for (var i = 0; i < 40; i++) {
        tester.binding.handlePointerEvent(
          const PointerScrollEvent(position: pointer, scrollDelta: Offset(0, 20)),
        );
      }
      await tester.pump();
      expect(camera.value.zoom, closeTo(fit.zoom, 1e-9));
    });

    testWidgets('a drag never shows more than 20 px past the scene', (tester) async {
      await host(tester);
      camera.focus(const Offset(1200, 600), zoom: 1);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.drag(find.byKey(const ValueKey('camera_area')), const Offset(3000, 3000));
      expect(camera.value.toScreen(_scene.topLeft).dx, closeTo(20, 1e-6));
      expect(camera.value.toScreen(_scene.topLeft).dy, closeTo(20, 1e-6));
      await tester.drag(find.byKey(const ValueKey('camera_area')), const Offset(-9000, -9000));
      expect(camera.value.toScreen(_scene.bottomRight).dx, closeTo(_view.width - 20, 1e-6));
      expect(camera.value.toScreen(_scene.bottomRight).dy, closeTo(_view.height - 20, 1e-6));
    });

    test('a scene smaller than the view stays centred', () {
      const cam = DashCamera(offset: Offset(-500, -500), zoom: 0.1);
      final kept = cam.keptOn(_scene, _view);
      _near(kept.centreOf(_view), _scene.center);
    });

    testWidgets('a window grown later leaves no empty bands: the camera settles', (tester) async {
      await host(tester);
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      await tester.pump();
      await tester.pump();
      const view = Size(1400, 900);
      final cam = camera.value;
      expect(cam.zoom, closeTo(DashCamera.covering(_scene, view).zoom, 1e-9));
      final (topLeft, bottomRight) = (
        cam.toScreen(_scene.topLeft),
        cam.toScreen(_scene.bottomRight),
      );
      expect(topLeft.dx, lessThanOrEqualTo(20 + 1e-6));
      expect(topLeft.dy, lessThanOrEqualTo(20 + 1e-6));
      expect(bottomRight.dx, greaterThanOrEqualTo(view.width - 20 - 1e-6));
      expect(bottomRight.dy, greaterThanOrEqualTo(view.height - 20 - 1e-6));
    });

    testWidgets('keys zoom, pan and fit once the flock has focus', (tester) async {
      await host(tester);
      final fit = camera.value;
      await tester.tap(find.byKey(const ValueKey('camera_area')));
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      expect(camera.value.zoom, closeTo(fit.zoom * 1.25, 1e-9));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(camera.value.offset.dx, greaterThan(fit.offset.dx));
      await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
      await tester.pumpAndSettle();
      _near(camera.value.offset, fit.offset);
      expect(camera.value.zoom, closeTo(fit.zoom, 1e-9));
    });

    testWidgets('under reduced motion a focus jumps', (tester) async {
      await tester.binding.setSurfaceSize(_view);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _Host((c) => camera = c),
        ),
      );
      await tester.pump();
      camera.focus(const Offset(1200, 600));
      expect(camera.isFlying, isFalse);
      _near(camera.value.centreOf(_view), const Offset(1200, 600));
    });
  });
}
