---
name: flutter-ui-stateless-stateful
description: "StatelessWidget vs StatefulWidget, lifecycle (initState, didUpdateWidget, dispose), local state vs parameters from the host app. Use when decomposing trees or managing controllers."
metadata:
  category: presentation
---

# Flutter StatelessWidget & StatefulWidget Expert Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Deciding whether to implement a component as `StatelessWidget` or `StatefulWidget`.
- Decomposing large widget trees into modular, fine-grained sub-widgets.
- Implementing modern widget constructors (`const`, `super.key`, private named parameters).
- Managing local ephemeral UI state (e.g. `AnimationController`, `TextEditingController`, `FocusNode`, `ScrollController`, `TabController`).
- Handling widget lifecycle methods (`initState`, didUpdateWidget, didChangeDependencies, `dispose`).
- Preventing unnecessary element tree churn and optimizing rebuild diffs.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | High-level presentation laws and routing. |
| **Constructor Standards** | [dart-use-primary-constructors](../dart-use-primary-constructors/SKILL.md) | `const` primary constructors with `super.key` and private declaring parameters (`final VoidCallback _onTap`). |
| **Performance** | [performance-rendering-build](../performance-rendering-build/SKILL.md) | RepaintBoundary and frame rate optimizations. |
| **Palette** | [flutter-ui-theme-extensions](../flutter-ui-theme-extensions/SKILL.md) | Resolving `PipitPalette` once in `build()` and passing colours down. |
| **Goldens** | [flutter-golden-tests](../flutter-golden-tests/SKILL.md) | Pinning a widget at a fixed state. |

---

## 3. Decision Matrix: StatelessWidget vs StatefulWidget vs Lifted State

| State Type | Example | Implementation Choice | Rationale |
| :--- | :--- | :--- | :--- |
| **Pure Presentation** | Card, Badge, User Avatar, Static Header | `StatelessWidget` with `const` constructor | 100% pure, no internal state, maximum element reuse. |
| **Ephemeral UI State** | Active tab index, text selection, hover expand, animation ticker | `StatefulWidget` (local `State<T>`) | Scoped strictly to the widget lifecycle. Disposed with the widget. |
| **Host-App State** | Which pose a bird is in, the chosen accessory, the theme | Owned by the host app and passed in as widget parameters | The package is a widget; it never owns application state. |

---

## 4. Element Tree Diffing & Modern Widget Construction

### The Helper Method Flaw:
```dart
// ❌ BAD: Forces complete subtree rebuild and loses element caching!
class const BadWidget({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(), // Re-allocates every time BadWidget rebuilds!
        _buildBody(),
      ],
    );
  }

  Widget _buildHeader() => Container(child: const Text('Header'));
  Widget _buildBody() => const SizedBox.shrink();
}
```

### The Standalone Widget Solution with Modern Constructors:
Widgets MUST adhere to modern Dart constructor conventions per [dart-use-primary-constructors](../dart-use-primary-constructors/SKILL.md):
- Declare a `const` primary constructor in the class header.
- Forward `super.key` as a super parameter.
- For encapsulated private parameters or callbacks, use a **private declaring parameter** (`required final VoidCallback _onRefresh`); callers still pass `onRefresh:`:

```dart
// ✅ GOOD: Reusable, diffable, and uses modern Primary Constructor syntax (Dart 3.13+)
class const GoodWidget({
  super.key,
  required final String title,
  required final VoidCallback _onRefresh, // Modern private declaring parameter
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderWidget(title: title),
        _BodyWidget(onRefresh: _onRefresh),
      ],
    );
  }
}

class const _HeaderWidget({
  super.key,
  required final String title,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(title);
}

class const _BodyWidget({
  super.key,
  required final VoidCallback onRefresh,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ElevatedButton(onPressed: onRefresh, child: const Text('Refresh'));
}
```

---

## 5. StatefulWidget Lifecycle Best Practices

```dart
class const FeatureSearchInput({
  super.key,
  required final String initialQuery,
  required final ValueChanged<String> onSubmitted,
}) extends StatefulWidget {
  @override
  State<FeatureSearchInput> createState() => _FeatureSearchInputState();
}

class _FeatureSearchInputState extends State<FeatureSearchInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // 1. Initialize controllers & listeners once
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant FeatureSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 2. React to parent property changes
    if (oldWidget.initialQuery != widget.initialQuery &&
        _controller.text != widget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    // 3. ALWAYS dispose controllers to prevent memory leaks
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _controller.clear(),
        ),
      ),
    );
  }
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Helper builder methods (`Widget _buildX()`) inside classes | **CRITICAL** | Extract to separate `StatelessWidget` classes. |
| Forgetting to call `.dispose()` on `TextEditingController` / `FocusNode` | **CRITICAL** | Call `.dispose()` inside `State.dispose()`. |
| Creating an `AnimationController` or `Ticker` per widget instance | **CRITICAL** | Read the shared clock (`PipitStage`) through a `ValueListenable`. |
| Caching in `State` what can be recomputed from widget parameters | **HIGH** | Compute it in `build()` or refresh it in `didUpdateWidget`. |
| Missing `const` on Stateless subtrees or omitting `super.key` | **MEDIUM** | Add `const` and `super.key` to all widget constructors. |

---

## 7. Verification Checklist

- [ ] All UI helper methods are converted into standalone `StatelessWidget` classes.
- [ ] Widgets use `const` primary constructors with `super.key`, and private declaring parameters (`final VoidCallback _onTap`) where encapsulation is required.
- [ ] Every `StatefulWidget` properly disposes of its controllers and focus nodes in `dispose()`.
- [ ] No clock, `Random()` or global read inside widget classes; time and seed arrive as parameters.
- [ ] Property changes from parent widgets are handled in `didUpdateWidget` if necessary.
- [ ] File line count remains strictly within 150–200 lines.
