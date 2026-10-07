---
name: code-review-advisor
description: "Senior review of the Pipit package against its laws: public API surface, zero dependencies, deterministic painting, palette-only colours, disposal, size limits, docs for pub.dev. Use ONLY when the user explicitly asks for a review: код рев'ю, code review, перевір код, оціни якість коду, знайди баги, find bugs."
metadata:
  category: quality
---

# Code Review & Technical Quality Advisor

## 1. Overview & When to Apply

This skill acts as a **strict senior Flutter package maintainer**. It audits modified or new code against the package laws in `CLAUDE.md`, the painting rules, the public API contract and pub.dev readiness.

### When to Activate:
Activate **ONLY** upon explicit user request in **any language**:
- **UK:** *"Зроби код-рев'ю останніх змін"*, *"Перевір код на баги і витоки"*, *"Оціни якість публічного API"*, *"Зроби технічний аудит"*
- **EN:** *"Do a code review of recent changes"*, *"Review for bugs and leaks"*, *"Audit the public API"*, *"Evaluate code quality"*

Do **NOT** activate automatically during regular code generation or editing.

---

## 2. Technical Audit Checklist & Standards

### 2.1 Package Contract (Laws 1, 2, 7)
- **Dependencies:** did `pubspec.yaml` gain anything beyond `flutter`, `flutter_test`, `flutter_lints`? (Must not.)
- **Barrel:** is every new public type exported from `lib/pipit.dart` on purpose, with `show` where a file mixes public and private? Did an internal (`PipitRenderer`, `PipitMotion`, geometry) leak into the barrel?
- **Breaking changes:** a renamed/removed export, a changed default, a new required parameter. Each needs a `CHANGELOG.md` entry and a version bump; prefer an optional parameter whose default keeps today's picture.
- **Imports:** `package:pipit/...` only; no relative imports; `material.dart` only in widget files.
- **Constructors:** primary constructors on every class; `const` where the fields allow it; `@immutable` value types with `==`/`hashCode` (and `lerp` where they animate).

### 2.2 Painting & Motion (Laws 3, 4)
- **Colours:** any `Color(0x…)` outside `PipitPalette.light` / `.dark`? Any `Theme.of(context).colorScheme` read inside the package?
- **Determinism:** does any `paint()` or motion function read `DateTime.now()`, `Random()` without the id seed, or a global? Same inputs must give the same pixels.
- **Allocation per frame:** `Path`, `Paint`, `List` or closure created inside `paint()`? `Path`s must be cached per look; `Paint`s owned by the renderer.
- **Repaint scope:** `setState` per frame, or a `shouldRepaint` that compares the time instead of the inputs? Is each bird under a `RepaintBoundary`?
- **Springs:** does a pose/expression/pointer change retarget `PipitPoseTransition` or does it cut?
- **Bounds:** does every new part, accessory or facing stay inside `PipitRenderer.bounds` (the bounds test covers it)?
- **Reduced motion & `TickerMode`:** still honoured after the change?

### 2.3 Widget Lifecycle & Memory
- **Listeners:** every `addListener` has a matching `removeListener` in `dispose()` and on `didChangeDependencies` when the stage changes.
- **Notifiers and tickers:** `ValueNotifier`, `Ticker` disposed; no `AnimationController` created per bird.
- **Semantics:** `semanticLabel` still required; `button` vs `image` still correct for tappable birds.
- **`didUpdateWidget`:** an `id` change reseeds idle; a pose/expression change retargets the spring.

### 2.4 Size, Docs & pub.dev (Law 5)
- **File length:** 150–200 lines; painters split by part or facing, no `_paintX()` grab-bag class, no `_buildX()` helpers.
- **Doc comments:** every exported member has a `///` written for a user, first sentence standalone, no restating of the name. `dart doc` and `dart pub publish --dry-run` clean.
- **README / CHANGELOG / `doc/pipit.png`:** updated for any visible change.
- **Tests:** a visible change has a probe, a motion test, or a golden in both palettes; no `pumpAndSettle()` under a live stage.

---

## 3. Mandatory Output Format

At the **end of the review**, provide an isolated, structured callout block (`> [!TIP]`), in the configured communication language:

```markdown
> [!TIP]
> ### 🛡️ Code Review & Technical Audit:
>
> - 🔴 **CRITICAL (fix now):**
>   - **[File / Member]:** [What breaks: a leaked internal, a per-frame allocation, a missing dispose, a new dependency].
>   - *Violation:* [Which law or rule].
>   - *Recommended fix:* [Concrete instruction or code].
>
> - 🟠 **HIGH (important):**
>   - **[File / Member]:** [A risky pattern or a breaking change without a CHANGELOG entry].
>   - *Recommended fix:* [Concrete solution].
>
> - 🟡 **MEDIUM / LOW (style and polish):**
>   - **[File / Member]:** [const, naming, a doc comment that restates the name, file length].
```

> [!NOTE]
> If the code satisfies every standard, output a concise confirmation that the change is ready to publish and complies with the package laws.

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Nitpicking without rationale | **MEDIUM** | Explain *why* and give the exact fix. |
| Passing a new dependency or a leaked internal | **CRITICAL** | Laws 1 and 2 are never waived. |
| Ignoring a missing `removeListener` / `dispose` | **HIGH** | Always flag listeners, notifiers and tickers without cleanup. |
| Accepting a visible change without a golden or probe | **HIGH** | Ask for the test and the redrawn `doc/pipit.png`. |

---

## 5. Review Verification Checklist

- [ ] `pubspec.yaml` unchanged in its dependency sections.
- [ ] Barrel exports reviewed; no internals leaked; breaking changes logged.
- [ ] No colour literals or theme reads inside painting code.
- [ ] `paint()` allocation-free and clock-free.
- [ ] Listener/notifier/ticker disposal verified.
- [ ] Docs, README, CHANGELOG and picture updated for visible changes.
