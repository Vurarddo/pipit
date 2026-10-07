---
name: git-commit-standards
description: "Conventional Commits and atomic commit practice. Use when staging changes, writing commit messages, or squashing history."
metadata:
  category: git
---

# Git Conventional Commits & Atomic Commit Standards

## 1. Overview & When to Apply

Use this skill whenever:
- Creating new commits for features, bugfixes, refactoring, tests, or documentation.
- Structuring commit messages according to the **Conventional Commits v1.0.0** specification.
- Splitting monolithic diffs into atomic, focused commits.
- Documenting breaking changes (`BREAKING CHANGE:`) or referencing issue trackers (`Closes #42`).
- Rewording or squashing messy commits during interactive rebase.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [git-workflow-hub](../git-workflow-hub/SKILL.md) | Central GitFlow workflow and rules. |
| **Branching** | [git-workflow-hub](../git-workflow-hub/SKILL.md) | Branch naming conventions and GitFlow roles. |
| **Rebase & Squash** | [git-rebase-conflict-resolution](../git-rebase-conflict-resolution/SKILL.md) | Squashing and rewording commit history. |
| **Static Analysis** | [dart-run-static-analysis](../dart-run-static-analysis/SKILL.md) | Quality gate verification before commit. |

---

## 3. Conventional Commits Structure

Every commit message MUST strictly adhere to this format:

```text
<type>(<scope>): <subject>

[optional body describing the motivation and contrast with previous behavior]

[optional footer(s): BREAKING CHANGE, Closes #123, Co-authored-by]
```

### 3.1 Allowed Types Matrix

| Type | When to Use | SemVer Impact | Example |
| :--- | :--- | :--- | :--- |
| **`feat`** | A new feature or capability for the user | **MINOR** (`0.x.0`) | `feat(auth): add biometrics login via local_auth` |
| **`fix`** | A bug fix for existing behavior | **PATCH** (`0.0.x`) | `fix(theme): resolve dark mode contrast on card border` |
| **`refactor`** | Code restructuring without changing functional behavior | Internal | `refactor(view): extract the feet painter into its own file` |
| **`perf`** | Performance improvement (rendering, memory, compute) | Internal / Patch | `perf(renderer): cache part paths per look` |
| **`test`** | Adding or correcting unit, widget, or integration tests | Internal | `test(pose): add a golden for the sleeping pose` |
| **`docs`** | Documentation changes only (README, comments, docs) | Internal | `docs(readme): describe the expression parameter` |
| **`chore`** | Maintenance, dependencies, config files | Internal | `chore(release): 0.2.0` |
| **`build`** | Build system, pubspec constraints, CI | Internal | `build(pubspec): raise the Flutter lower bound to 3.47` |
| **`ci`** | CI/CD configuration files and scripts | Internal | `ci(github): add automated analyze and test workflow` |

---

## 4. Atomic Commit Guidelines

An **atomic commit** encapsulates exactly ONE logical change that builds and passes all tests independently.

### Rules of Atomic Commits:
1. **Never Mix Unrelated Changes:** Do NOT bundle a feature implementation with unrelated typo fixes or dependency updates in the same commit.
2. **Never Commit Broken Code:** Every commit in the repository must be in a compilable, testable state.
3. **Stage Specific Files (`git add -p`):** Use interactive patching `git add -p` or specific file paths to stage only relevant changes.

---

## 5. Concrete Examples

### 5.1 Simple Atomic Feature Commit
```bash
git commit -m "feat(settings): add dynamic theme switcher toggle"
```

### 5.2 Commit with Detailed Body & Issue Reference
```bash
git commit -m "fix(stage): stop the ticker under TickerMode

A stage inside a hidden tab kept scheduling frames, so a screen of birds
below the top route cost a full frame budget. The ticker now comes from the
widget's vsync and is muted with the subtree.

Closes #12"
```

### 5.3 Breaking Change Commit
```bash
git commit -m "refactor(api)!: migrate UserRepository to return Domain Result models

BREAKING CHANGE: UserRepository methods now return Result<User, ApiException>
instead of throwing raw DioException."
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Vague commit messages (`"wip"`, `"fix"`, `"update"`, `"changes"`) | **CRITICAL** | Use `<type>(<scope>): <clear description>`. |
| Committing or pushing code with static analysis or test errors | **CRITICAL** | Run `dart format .`, `dart analyze --fatal-infos` and `flutter test`. |
| Bundling multiple independent features in one giant commit | **HIGH** | Split into multiple atomic commits using `git add <files>`. |
| Putting commit subject in past tense (`"fixed issue"`, `"added pose"`) | **MEDIUM** | Use imperative present tense (`"fix issue"`, `"add pose"`). |
| Capitalizing the first letter of subject or adding trailing dot | **MEDIUM** | Use lowercase start and no period: `feat(ui): add button`. |

---

## 7. Commit Verification Checklist

- [ ] Commit message matches `<type>(<scope>): <subject>` syntax.
- [ ] Subject is in imperative, present tense ("add", "fix", "refactor") and ≤ 72 characters.
- [ ] Type accurately reflects the nature of the change (`feat`, `fix`, `refactor`, etc.).
- [ ] Scope identifies the part of the package (`pose`, `palette`, `stage`, `view`, `example`, `readme`).
- [ ] Change is atomic and does not contain unrelated modifications.
- [ ] `dart format .` executed without formatting errors.
- [ ] `dart analyze --fatal-infos` passes cleanly with zero diagnostics.
- [ ] `flutter test` passes with 100% success rate before pushing.
