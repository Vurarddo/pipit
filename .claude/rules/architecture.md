# Package Architecture & Public API Rules

> **Parent Navigator:** [CLAUDE.md](../CLAUDE.md)  
> **Related Skills:** [`flutter-procedural-character`](../skills/flutter-procedural-character/SKILL.md), [`dart-use-primary-constructors`](../skills/dart-use-primary-constructors/SKILL.md), [`dart-write-documentation`](../skills/dart-write-documentation/SKILL.md)

---

## 1. Package Layout

```text
lib/
├── pipit.dart                 # The barrel: the whole public API, nothing else
└── src/                       # Private implementation, one concern per file
    ├── pipit_view.dart        # The widget: lifecycle, pointer following, semantics
    ├── pipit_stage.dart       # The clock every bird reads (one per screen)
    ├── pipit_painter.dart     # CustomPainter: composes renderer, motion, transition
    ├── pipit_renderer.dart    # Paints one bird at one PipitMotion; owns the shared bounds
    ├── pipit_*_view.dart      # One file per facing (front, side, back)
    ├── pipit_geometry.dart    # Unit geometry of the body parts
    ├── pipit_motion.dart      # Idle (breath, blink) derived from the bird's id
    ├── pipit_pose*.dart       # Poses as flat value sets and the spring between them
    ├── pipit_look.dart        # The twelve colours of one bird
    ├── pipit_palette.dart     # ThemeExtension with the light and dark palettes
    └── ...                    # accessories, headwear, feet, face, ink, reactions
example/lib/main.dart          # The pub.dev example: every pose, accessory and facing
test/                          # Widget and pure-Dart tests, one file per concern
tool/screenshot_test.dart      # Draws doc/pipit.png for the README
```

- **One concern per file.** A file holds one widget, one painter, one value type or one closely related set of enums. When a painter outgrows ~150 lines, split by body part or by facing, not by "helpers".
- **No layers.** There is no domain, data or presentation split: the package is a widget and the painting behind it. Do not introduce `core/`, `features/` or a DI container.
- **Geometry is data, time is an argument.** Painters receive a look, a pose and the time in seconds; they never read a clock. See [`flutter-procedural-character`](../skills/flutter-procedural-character/SKILL.md).

---

## 2. Public API Surface (Law 2)

1. **The barrel is the contract.** `lib/pipit.dart` exports exactly the types a user needs: the widget, the stage, the look, the palette, and the enums and value types that are its parameters. Internals (`PipitRenderer`, `PipitMotion`, geometry, views) are never exported, even when tests import them through `package:pipit/src/...`.
2. **Partial exports are explicit.** When a file holds both public and private types, export with `show` (as `pipit_pose.dart` does), never the whole file.
3. **Every exported declaration has a `///` comment** written for a user who has not read the source, following [`dart-write-documentation`](../skills/dart-write-documentation/SKILL.md). `dart doc` must run clean.
4. **Additions are cheap, removals are releases.** Renaming or removing an exported member, or changing a default, is a breaking change: it needs a `CHANGELOG.md` entry and a major (or pre-1.0 minor) version bump. Prefer adding an optional named parameter with a default that keeps today's picture identical.
5. **Keep it a widget.** No global state, no singletons, no static mutable caches. A `PipitStage` is the only shared thing, and it is an `InheritedWidget` scoped to its subtree.
6. **Every value type is immutable and comparable:** `@immutable`, `const` constructor, `==`/`hashCode` (or `lerp` where it animates). Users put them in `const` widget trees.

---

## 3. Constructors & Imports (Law 7)

- **Primary constructors everywhere.** Widgets as `class const PipitView({super.key, required final String id, ...}) extends StatefulWidget`; value types as `class const PipitLook({required final Color body, ...})`. Only a `factory` that computes its fields (`PipitLook.fromBody`) keeps the in-body shape. Details in [`dart-use-primary-constructors`](../skills/dart-use-primary-constructors/SKILL.md).
- **Package imports only:** `import 'package:pipit/src/...';`. Relative imports are forbidden; the only exception is `part` / `part of`, which this package does not use.
- **Import order:** `dart:` imports, blank line, `package:flutter/...`, blank line, `package:flutter_test/...` (tests), blank line, `package:pipit/...`. Sorted alphabetically inside each group. There is no sorter tool; keep it by hand and let `dart format` do the rest.
- **Minimal Flutter imports.** A file that only needs `Color`, `Offset` or `Paint` imports `package:flutter/painting.dart` or `dart:ui`, not `material.dart`. Only the widget files need `material.dart`.
