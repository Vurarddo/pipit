# Physics Spring Simulation Guide

This reference demonstrates natural gesture-driven drag and spring-back motion using `SpringSimulation` and `AnimationController`.

---

## 1. Architectural Rules

1. **Natural Motion:** Use `SpringSimulation` to calculate deceleration and bounce based on gesture release velocity.
2. **Space Measurement:** Use `MediaQuery.sizeOf(context)` to compute normalized coordinates rather than `MediaQuery.of(context)` to avoid keyboard/rebuild storms.
3. **Controller Cleanup:** Always dispose `AnimationController` in `State.dispose()`.

---

## 2. Implementation Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class const PhysicsSpringDraggable({
  super.key,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<PhysicsSpringDraggable> createState() => _PhysicsSpringDraggableState();
}

class _PhysicsSpringDraggableState extends State<PhysicsSpringDraggable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSpringAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onPanDown: (details) => _controller.stop(),
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) {
        _runSpringAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: widget.child,
      ),
    );
  }
}
```
