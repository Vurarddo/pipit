# Code Quality, Formatting, Git & Release Rules

> **Parent Navigator:** [CLAUDE.md](../CLAUDE.md)  
> **Related Skills:** [`git-workflow-hub`](../skills/git-workflow-hub/SKILL.md), [`dart-run-static-analysis`](../skills/dart-run-static-analysis/SKILL.md), [`dart-write-documentation`](../skills/dart-write-documentation/SKILL.md)

---

## 1. Formatting & Linting (per `analysis_options.yaml`)

- **Lints:** `package:flutter_lints/flutter.yaml`, nothing custom. Do not add lint packages (Law 1).
- **Page width:** 100 characters.
- **Trailing commas:** preserved (`trailing_commas: preserve`), so a short constructor call stays on one line and a long one keeps its comma.
- **Analysis must be silent:** `dart analyze --fatal-infos` reports nothing. The example app has its own `analysis_options.yaml` and is analysed separately from `example/`.
- **pub.dev score:** the package is published, so `dart pub publish --dry-run` must pass with no warnings: every exported member documented, `CHANGELOG.md` current, `README.md` example compiling.

---

## 2. Git Push & Publish Policy, Mandatory Pre-Push Quality Gate

- **Explicit User Consent Required:** AI agents MUST NEVER run `git push` or `dart pub publish` unless the user gives direct, explicit instruction (e.g., "запуш", "push", "опублікуй", "publish"). Staging and local commits (`git add`, `git commit`) can be done as requested.
- **Mandatory 3-Step Pre-Push Quality Gate:** Even upon explicit push instruction, the agent MUST ALWAYS execute and verify this sequence BEFORE `git push`:
  1. `dart format --output=none --set-exit-if-changed .` (formatting compliance; covers `lib`, `test`, `tool` and `example`)
  2. `dart analyze --fatal-infos` (zero errors, warnings, or infos)
  3. `flutter test` (100% pass rate; `tool/screenshot_test.dart` is excluded by its location)

  *If ANY check fails, the push MUST be aborted, the issue resolved, and checks re-verified before pushing.*
- **Release gate (before `dart pub publish`):** the 3-step gate, then `dart pub publish --dry-run`, then `flutter test tool/screenshot_test.dart --update-goldens` if anything visible changed, so `doc/pipit.png` matches the release. The version in `pubspec.yaml`, the top entry of `CHANGELOG.md`, the `^` constraint in the README install snippet, and the git tag `vX.Y.Z` must agree.
- **Branches:** `main` is the only long-lived branch and is published from. Work on short-lived `feat/…`, `fix/…` branches and merge with a linear history. There is no `develop` and no release branch.

---

## 3. Doc-Comment Hygiene (Comment the Why, Not the What)

- **Never restate the declaration.** A `///` comment that repeats the member name is prohibited: `/// The pose of the bird.` above `pose` carries no information. If a declaration needs a sentence to be understood, rename it first.
- **Public API comments are for the user of the package**, not the maintainer: say what the bird does with the value, what the default is, and what happens at the edges (`null` seconds = a still picture). The first sentence stands alone in `dart doc` listings.
- **Comment only what the code cannot carry:** the reason for a magic number (a spring stiffness, a blink interval, a 1.5-width reach), the meaning of an opaque literal, a caveat that is easy to break, or a tradeoff and the alternative rejected.
- **Placement beats volume.** Project-wide conventions belong in `.claude/rules/`. Architecture and workflows belong in `README.md`. Only line-local rationale belongs in a comment.
- Full Effective Dart formatting rules: [`dart-write-documentation`](../skills/dart-write-documentation/SKILL.md).

---

## 4. Complete Rudiment & Dead Code Elimination Protocol

- **Zero Residue Refactoring:** When a pose, accessory, facing or parameter is removed, NEVER leave partial residues (an unused enum value, a dead branch in a `switch`, an orphaned geometry constant, a stale README line).
- **Mandatory Reverse Search:** Always search the codebase (Grep / `rg`) after removing something to purge downstream references, including `example/`, `tool/`, `README.md` and `CHANGELOG.md`.
- **Clarification Trigger:** If removing a default changes what users see (a bird that used to be `standing` is now something else), ask the user rather than silently choosing.
