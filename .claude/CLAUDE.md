# Pipit Package Constitution (Claude Code)

Project instructions for this repository (`.claude/CLAUDE.md`). Detailed rules live in `.claude/rules/` (auto-loaded, some scoped by `paths:`), and on-demand knowledge lives in `.claude/skills/` (auto-selected by their `description`).

Pipit is a **pub.dev package**: one hand-drawn bird widget (`PipitView`) and its clock (`PipitStage`), painted on a canvas with no assets and no dependencies beyond Flutter. The repository is a small monorepo: `packages/pipit` is the bird, and a second package, `packages/pipit_sounds`, gives the bird a voice (WAV assets synthesised by a script kept outside the repository, played through `audioplayers`); it is the only place a dependency or an asset may live. There is no app here, no backend, no network, no state-management framework. Every rule below is written for libraries whose users are other Flutter developers.

## 1. Communication & Language

- **Language resolution:** Use the language set in `./CLAUDE.local.md` — **repository root, not `.claude/`**; that is the only location Claude Code loads it from (git-ignored, loaded automatically). Format: `- **Configured Communication Language:** <Language>`.
  - If no such line exists: answer in English on the first turn, ask the user for their preferred language, then create/update `./CLAUDE.local.md` with that line. Never commit it.
- **User chat & direct responses:** ALWAYS use the configured communication language.
- **Internal reasoning, plans & artifacts:** written in **English**.
- **Source code & identifiers:** All code, filenames, variables, tests, `///` doc-comments, `README.md`, `CHANGELOG.md` and git commits MUST stay in **English**. They are published on pub.dev.
- **Role:** Senior Flutter package author. Write small, deliberate, production-ready code. Avoid over-engineering, "magic" code, and redundant abstractions. A public API is a promise; add to it slowly.
- **Concise rationale:** No lengthy explanations for standard boilerplate. Give brief rationale ONLY for non-obvious geometry, motion, or API-design choices.

---

## 2. Zero-Tolerance Constraints (Unbreakable Package Laws)

These seven laws always apply. Each one is stated here in full and elaborated in exactly one rule file — the **Detail** column. Never restate a law elsewhere; extend it in its rule file.

| # | Law | Detail |
| :-- | :--- | :--- |
| 1 | **Zero Dependencies.** `pipit`'s `pubspec.yaml` depends on `flutter` only; dev dependencies are `flutter_test` and `flutter_lints`. No package is added for code generation, animation, images, or testing. `pipit_sounds` may depend on `pipit` and one audio plugin, nothing more. | [workspace_and_tools.md](rules/workspace_and_tools.md) |
| 2 | **One Barrel, Private Internals.** `lib/pipit.dart` is the only public entry; everything under `lib/src/` is private unless the barrel exports it. The public surface is small, documented, and changed only with a `CHANGELOG.md` entry. | [architecture.md](rules/architecture.md) |
| 3 | **Colours Come From the Palette.** Painting code receives resolved `Color`s from `PipitLook`, which is built from `PipitPalette` (a `ThemeExtension`). The only `Color(0x…)` literals in `lib/` are the two palette constants. | [ui_and_theme.md](rules/ui_and_theme.md) |
| 4 | **Deterministic Painting.** A painter reads no clock, `Random()` or `DateTime.now()`; time and seed come in as arguments, so goldens and tests are stable. Nothing is allocated per frame. | [ui_and_theme.md](rules/ui_and_theme.md) |
| 5 | **Widget Decomposition & Size Limits.** Max 150–200 lines per file; never use helper `_buildX()` methods — extract a widget, or a painter class per body part. | [ui_and_theme.md](rules/ui_and_theme.md) |
| 6 | **Git Push Protection & Quality Gate.** Never `git push` or `dart pub publish` without explicit user instruction, and always pass the 3-step gate first. | [quality_and_git.md](rules/quality_and_git.md) |
| 7 | **Primary Constructors & Package Imports.** Every class declares its fields through a Dart 3.13 primary constructor; every import is `package:pipit/...`, never relative. | [architecture.md](rules/architecture.md) |

> Laws 3, 4 and 5 live in a path-scoped rule file that loads only for matching files, so the law text above is what always applies.

---

## 3. Rules (`.claude/rules/`)

Loaded automatically by Claude Code. Rules with `paths:` frontmatter load only when Claude works with matching files.

| Rule file | Scope | Loads |
| :--- | :--- | :--- |
| [architecture.md](rules/architecture.md) | Package layout, public API surface, `lib/src/` structure, constructors and imports. | always |
| [quality_and_git.md](rules/quality_and_git.md) | Formatting, analysis, doc-comment hygiene, Git push policy, Pre-Push Quality Gate, releases. | always |
| [workspace_and_tools.md](rules/workspace_and_tools.md) | Zero-dependency invariant, the example app, screenshot tool, stale pointer policy. | always |
| [ui_and_theme.md](rules/ui_and_theme.md) | Painting, palette, motion, accessibility, size limits. | `packages/pipit/{lib,example/lib,tool,test}/**` |

---

## 4. Skills, Hubs & Commands

- **Skills:** `.claude/skills/<name>/SKILL.md` (flat; one level). Claude selects them by `description`; the `metadata.category` field groups them by domain.
- **Hubs (entry points per domain):** `flutter-ui-hub` (painting, motion, widgets), `performance-hub` (frame cost), `testing-hub` (widget and golden tests), `git-workflow-hub` (commits, gate, releases), `mcp-tooling-hub` (Dart MCP server). Each hub links to its leaf skills.
- **Commands:** `.claude/commands/v-*.md` — `/v-audit-skills`, `/v-delete-skill`, `/v-session-handoff`, `/v-skill-creator`.
- **MCP servers:** only `dart` (user scope, `~/.claude.json`); no project `.mcp.json`. After Dart/Flutter changes in a running example, hot reload/restart via the Dart MCP tools.
- **Running the package:** there is no app to run; each package has an `example/` (web only is checked in) and the README picture is drawn from `packages/pipit` by `flutter test tool/screenshot_test.dart --update-goldens`. Commands run from the package directory (`packages/pipit`, `packages/pipit_sounds`); `dart analyze` from the repository root covers all of them.

---

## 5. Rule & Skill Evolution Protocol

1. **Keep `CLAUDE.md` lean** (target <120 lines): it is the constitution, not a catalog.
2. **Modular placement:** New rules go in `.claude/rules/<domain>.md` (add `paths:` globs when file-specific) and get one row in Section 3.
3. **Skills are flat:** New skills go in `.claude/skills/<name>/`; follow [skill-creator](skills/skill-creator/SKILL.md) and audit with [skill-auditor](skills/skill-auditor/SKILL.md). A skill that describes an app layer this package does not have (BLoC, repositories, DI, networking, flavors) does not belong here.
4. **Stale pointers:** When files move or skills are added/removed, update every router (this file, rules, hub routing tables) in the same turn.
