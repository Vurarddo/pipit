# Implicit & Explicit Animations Guide

> **Parent Skill:** [flutter-ui-animations](../SKILL.md)

The two tiers with full examples: implicit widgets for single state changes, an explicit controller for choreographed motion.

---

## 1. Tier 1: Implicit Animations (Zero Boilerplate)

Use implicit widgets whenever state changes trigger a transition without needing pause, rewind, or loop controls:

### 1.1 AnimatedContainer & AnimatedCrossFade
```dart
import 'package:flutter/material.dart';

class const ExpandableFilterCard({
  super.key,
  required final bool isExpanded,
  required final VoidCallback onToggle,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.all(isExpanded ? 24.0 : 12.0),
      decoration: BoxDecoration(
        color: isExpanded ? colorScheme.primaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(isExpanded ? 16 : 8),
      ),
      child: InkWell(
        onTap: onToggle,
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const Text('Tap to expand details'),
          secondChild: const Text('Detailed filter options and settings are visible here.'),
        ),
      ),
    );
  }
}
```

---

## 2. Tier 2: Explicit Choreographed Animations

Use `AnimationController` + `AnimatedBuilder` for repeatable, staggered, or controller-driven transitions.

### 2.1 Critical Rule: Reuse the Static `child` Parameter
Always pass heavy subtrees into the `child` argument of `AnimatedBuilder`. This transforms the element on the raster layer without executing the subtree's Dart build method on every frame tick!

```dart
class const StaggeredEntranceCard({super.key}) extends StatefulWidget {

  @override
  State<StaggeredEntranceCard> createState() => _StaggeredEntranceCardState();
}

class _StaggeredEntranceCardState extends State<StaggeredEntranceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Initialize controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 2. Staggered curves (Intervals)
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    // 3. ALWAYS dispose controller to prevent resource leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check accessibility: disable animation if requested by user
    if (MediaQuery.disableAnimationsOf(context)) {
      return const HeavyStaticCardContent();
    }

    return AnimatedBuilder(
      animation: _controller,
      // Pass static subtree into `child` so it is NOT rebuilt on each animation tick!
      child: const HeavyStaticCardContent(),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child, // Reused static child
          ),
        );
      },
    );
  }
}
```
