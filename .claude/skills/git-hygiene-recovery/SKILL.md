---
name: git-hygiene-recovery
description: "Stash, clean, secret protection, reflog recovery, cherry-pick. Use when recovering lost commits, cleaning artifacts, or preventing leaked secrets."
metadata:
  category: git
---

# Git Repository Hygiene, Stash & Disaster Recovery Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Safeguarding credentials, API keys, and environment files (`.env`, `config/env_*.json`) from being committed.
- Temporarily saving and switching work in progress via `git stash`.
- Cleaning untracked build artifacts, generated files, or ignored temp files (`git clean`).
- Recovering accidentally deleted branches or commits using `git reflog`.
- Selectively porting specific bug fixes or commits across branches with `git cherry-pick`.
- Maintaining `.gitignore` rules for Flutter, Dart, iOS, Android, and macOS/IDE files.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [git-workflow-hub](../git-workflow-hub/SKILL.md) | Central GitFlow workflow and rules. |
| **Branching** | [git-workflow-hub](../git-workflow-hub/SKILL.md) | Working with feature, release, and hotfix branches. |
| **Rebase & Conflicts** | [git-rebase-conflict-resolution](../git-rebase-conflict-resolution/SKILL.md) | Handling conflicts after cherry-pick or stash pop. |

---

## 3. Git Stash Workflows

Use `git stash` to set aside uncommitted work without creating junk commits:

### 3.1 Save Stash with Descriptive Name
```bash
# Save tracked and untracked changes with a descriptive message
git stash push -u -m "wip: profile avatar upload layout"
```

### 3.2 List & Inspect Stashes
```bash
# View list of saved stashes
git stash list

# Inspect diff of a specific stash
git stash show -p stash@{0}
```

### 3.3 Apply & Restore Stash
```bash
# Apply and immediately remove from stash list:
git stash pop

# Apply while keeping in stash list:
git stash apply stash@{0}

# Create a fresh branch directly from a stash:
git stash branch feature/resumed-avatar-work stash@{0}
```

---

## 4. Disaster Recovery with `git reflog`

Git records every HEAD movement (commits, rebases, checkouts, resets) in the **reflog**. Commits are rarely lost permanently.

### 4.1 Recovering an Accidentally Deleted Branch or Commit
```bash
# 1. View reflog history
git reflog

# Output example:
# e4f5a1b (HEAD -> main) HEAD@{0}: reset: moving to HEAD~1
# a1b2c3d HEAD@{1}: commit: feat(auth): complete oauth flow
# 7d8e9f0 HEAD@{2}: checkout: moving from feature/oauth to main

# 2. Identify the commit hash before the mistake (e.g. a1b2c3d)

# 3. Restore to a new branch:
git checkout -b feature/recovered-oauth a1b2c3d
```

### 4.2 Undoing a Bad Hard Reset (`git reset --hard`)
```bash
# Reset HEAD back to the state before the hard reset:
git reset --hard HEAD@{1}
```

---

## 5. Cherry-Picking Specific Commits

Use `git cherry-pick` to apply an existing commit from another branch into your current branch:

```bash
# 1. Switch to target branch (e.g. hotfix or main)
git checkout main

# 2. Cherry-pick specific commit by hash
git cherry-pick a1b2c3d

# If conflicts occur: resolve them, stage, and continue:
# git add <resolved-files>
# git cherry-pick --continue

# To abort if needed:
# git cherry-pick --abort
```

---

## 6. Repository Hygiene & Secrets Protection

### 6.1 Critical `.gitignore` Rules (Flutter & Dart)
Ensure the following are NEVER committed:
```gitignore
# Sensitive Environment & Credentials
config/env_*.json
!config/env_template.json
*.keystore
*.jks
key.properties
GoogleService-Info.plist
google-services.json

# Flutter & Dart Build Outputs
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
build/
ephemeral/

# IDE & OS Artifacts
.DS_Store
.idea/
*.iml
.vscode/
```

### 6.2 Cleaning Untracked Files Safely
```bash
# Dry-run: see what WOULD be removed
git clean -nd

# Perform clean: remove untracked files and directories (excluding ignored)
git clean -fd

# Remove all untracked AND ignored build artifacts (dangerous):
git clean -fdx
```

### 6.3 Automated Pre-Push Quality Gate via Git Hooks
The repository ships no Git hooks; the agent runs the gate by hand before every push, in this order:
1. `dart format --output=none --set-exit-if-changed .` (zero formatting errors)
2. `dart analyze --fatal-infos` (zero warnings or infos)
3. `flutter test` (100% test success rate)

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Committing files with real API keys or private keys | **CRITICAL** | Remove immediately, rotate keys, add to `.gitignore`. |
| Running `git clean -fdx` without prior dry-run (`-nd`) | **HIGH** | Always run `git clean -nd` first to preview deleted files. |
| Using `git stash drop` before verifying changes applied cleanly | **HIGH** | Use `git stash pop` or keep with `git stash apply`. |
| Excessive cherry-picking instead of proper GitFlow merging | **MEDIUM** | Use GitFlow branch merges; reserve cherry-picking for isolated fixes. |

---

## 8. Hygiene & Recovery Verification Checklist

- [ ] `.gitignore` protects all local `config/env_*.json` and signing keys.
- [ ] No credential or secret files appear in `git status`.
- [ ] Stashes are named descriptively (`git stash push -m "..."`).
- [ ] `git clean` was tested with dry-run before execution.
- [ ] `git reflog` is referenced when recovering corrupted local state.
- [ ] Pre-push quality gate run by hand: format, analyze, test.
