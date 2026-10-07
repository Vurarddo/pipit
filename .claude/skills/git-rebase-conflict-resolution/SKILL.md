---
name: git-rebase-conflict-resolution
description: "Interactive rebase, squashing, upstream sync, conflict resolution. Use when rebasing a feature branch or resolving merge conflicts."
metadata:
  category: git
---

# Git Interactive Rebase & Conflict Resolution Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Syncing a feature branch with the latest changes from `main` without creating noisy merge commits.
- Cleaning up intermediate "wip", "typo", or "test" commits via interactive rebase (`git rebase -i`).
- Squashing multiple small commits into atomic Conventional Commits prior to opening a PR.
- Resolving merge or rebase conflicts methodically without losing code or breaking functionality.
- Safely aborting a broken rebase or merge operation (`git rebase --abort`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [git-workflow-hub](../git-workflow-hub/SKILL.md) | Central GitFlow workflow and rules. |
| **Commit Standards** | [git-commit-standards](../git-commit-standards/SKILL.md) | Rewording squashed commits to Conventional Commits. |
| **Recovery** | [git-hygiene-recovery](../git-hygiene-recovery/SKILL.md) | Recovering from rebase errors via `git reflog`. |
| **Static Analysis** | [dart-run-static-analysis](../dart-run-static-analysis/SKILL.md) | Verifying code compiles after conflict resolution. |

---

## 3. Interactive Rebase Commands Cheatsheet

When running `git rebase -i HEAD~N` or `git rebase -i origin/main`, use these action verbs:

| Command | Action | When to Use |
| :--- | :--- | :--- |
| **`pick`** | Keep the commit as is | Primary commits that represent complete logical steps. |
| **`reword`** | Keep commit content but edit commit message | Fixing non-conventional or typo commit messages. |
| **`squash`** (`s`) | Melds commit into the previous commit and prompts for a combined message | Combining related feature work into one commit. |
| **`fixup`** (`f`) | Melds commit into previous commit, discarding this commit's message | Combining minor typo/formatting fixes into the parent commit. |
| **`drop`** (`d`) | Completely removes the commit | Discarding accidental or temporary debug commits. |

---

## 4. Rebase Workflows

### 4.1 Syncing Feature Branch with `origin/main`
```bash
# 1. Fetch latest remote state
git fetch origin

# 2. Start rebase onto main
git rebase origin/main

# If no conflicts: rebase completes cleanly.
# If conflicts occur: proceed to section 5 below.
```

### 4.2 Squashing Commits Interactively
To clean up the last 4 commits on your feature branch:

```bash
git rebase -i HEAD~4
```

In the editor:
```text
pick a1b2c3d feat(auth): add login bloc state management
squash e4f5g6h wip: add form validation logic
fixup i7j8k9l fix typo in bloc event
fixup m1n2o3p format files
```

Save and close. In the next editor screen, write a clean Conventional Commit message summarizing the combined work.

---

## 5. Step-by-Step Conflict Resolution Workflow

When Git pauses with a conflict during `rebase` or `merge`:

### Step 1: Identify Conflicted Files
```bash
git status
# Conflicted files are listed under "Unmerged paths" (both modified / both added)
```

### Step 2: Open and Inspect Conflict Markers
Look for conflict delimiters inside the affected files:

```dart
<<<<<<< HEAD (current state on branch)
final Color cardColor = context.colorScheme.surfaceContainerLow;
=======
final Color cardColor = context.colorScheme.surface;
>>>>>>> feat(theme): updated surface token (incoming commit)
```

### Step 3: Resolve the Code
1. Edit the file to keep the correct intended logic.
2. Remove all `<<<<<<<`, `=======`, and `>>>>>>>` markers.
3. Save the file.

### Step 4: Validate Code Integrity
Run static analysis and tests to ensure the conflict resolution did not break the build:
```bash
dart format .
dart analyze
flutter test
```

### Step 5: Mark as Resolved & Continue Rebase
```bash
# Stage resolved files
git add path/to/resolved_file.dart

# Continue rebase (DO NOT use git commit here!)
git rebase --continue
```
Repeat for any subsequent commits until `Applying: ...` finishes.

---

## 6. Safe Escape Hatches (Aborting Rebase)

If a rebase becomes too messy or you make a mistake:

```bash
# Completely abort the rebase and return to the exact pre-rebase state:
git rebase --abort

# If in a merge conflict:
git merge --abort
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Running `git commit` in the middle of a rebase conflict | **CRITICAL** | Use `git add <files>` and then `git rebase --continue`. |
| Rebasing shared branches (`main`) | **CRITICAL** | Only rebase private feature/bugfix branches. |
| Force-pushing without pre-push quality gate verification | **CRITICAL** | Run import sorter, `dart analyze --fatal-infos`, and `flutter test` before pushing. |
| Force-pushing without `--force-with-lease` | **HIGH** | Use `git push --force-with-lease origin <branch>`. |
| Leaving uncommitted conflict markers in code | **HIGH** | Search for `<<<<<<<` before staging. |
| Blindly accepting "theirs" or "ours" without understanding code | **HIGH** | Carefully inspect both sides of the diff. |

---

## 8. Rebase Verification Checklist

- [ ] Feature branch history is rebased cleanly onto latest `origin/main`.
- [ ] Intermediate "wip" or "fixup" commits are squashed.
- [ ] No conflict markers (`<<<<<<<`) remain in the codebase.
- [ ] Mandatory Pre-Push Quality Gate passed: `dart format --output=none --set-exit-if-changed .`, `dart analyze --fatal-infos`, and `flutter test`.
- [ ] Pushing updated rebased history uses `git push --force-with-lease`.
- [ ] AI Agent received explicit user instruction to push (e.g. "запуш", "push").
