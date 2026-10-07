# Workspace, Tooling & Tech Stack Rules

> **Parent Navigator:** [CLAUDE.md](../CLAUDE.md)  
> **Related Skills:** [`mcp-tooling-hub`](../skills/mcp-tooling-hub/SKILL.md), [`flutter-golden-tests`](../skills/flutter-golden-tests/SKILL.md)

---

## 1. Tech Stack Invariant (Law 1)

- **`dependencies:` is `flutter` only.** The package promises "no assets or dependencies" on pub.dev; every added package is a promise broken for every user. Do not add animation, vector, image, state-management, code-generation or utility packages, however small.
- **`dev_dependencies:` is `flutter_test` and `flutter_lints` only.** No golden packages, no mocking packages, no import sorters, no `build_runner`. Tests use `matchesGoldenFile` and hand-written fakes.
- **The example is as plain as the package:** `example/pubspec.yaml` depends on `flutter` and `pipit` (by path). It shows the API, not a framework.
- **No code generation.** There are no `*.g.dart` or `*.freezed.dart` files; `copyWith`, `==` and `hashCode` are written by hand, which is why value types stay small.
- If a task seems to need a package, say so and ask; do not add it.

---

## 2. Running Things

- **There is no app to run.** `flutter run` applies only inside `example/` (`cd example && flutter run -d chrome`); only the web platform is checked in, and `flutter create .` in `example` adds others locally without committing them.
- **README picture:** `flutter test tool/screenshot_test.dart --update-goldens` redraws `doc/pipit.png` (both palettes, every pose and accessory). Rerun it whenever a visible change lands; the PNG is committed and shown on pub.dev.
- **Dart MCP server:** the only MCP server in use (user scope). Use `hot_reload` / `hot_restart` against a running example, `analyze_files` for quick checks, and `pub_dev_search` only to answer questions about the ecosystem, never to add a dependency. Catalog in [`mcp-tooling-hub`](../skills/mcp-tooling-hub/SKILL.md).
- **`.claude/launch.json`** holds the preview configuration that serves the example on the web for the in-app browser.

---

## 3. Router Maintenance & Stale Pointer Policy

- When a file moves, a skill is added or removed, or a rule changes scope, the agent MUST update the corresponding router (`CLAUDE.md`, `.claude/rules/`, hub routing tables) within the **same turn**.
- *A stale pointer is worse than no pointer.* Always maintain 100% path accuracy and valid relative links.
- Skills describing app layers this package does not have (BLoC, repositories, DI, networking, flavors, l10n, analytics) were deliberately removed; do not recreate them here.
