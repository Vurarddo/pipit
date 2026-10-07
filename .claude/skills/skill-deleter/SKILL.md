---
name: skill-deleter
description: "Deletes a skill and scrubs every cross-reference in CLAUDE.md, rules, commands, and other skills. Use via /v-delete-skill or when asked to remove a skill."
metadata:
  category: skill-management
---

# Skill Deleter & Reference Cleaner

## 1. Overview & Deletion Safeguards

When removing an AI skill from a project, simply deleting the folder is not enough:
- Stale links and dead references in other skills or `CLAUDE.md` cause broken navigation ("stale pointers").
- Hub skills that route to the removed skill keep pointing at a non-existent path unless their routing tables are cleaned.

This skill provides a zero-leakage, safe removal procedure for any skill in the workspace.

---

## 2. End-to-End Deletion Workflow

When invoked via `/v-delete-skill` or requested by the user:

### Step 1: Identify Target Skill & Scan References
Identify the skill name to delete (e.g., `project-advisor` or `my-custom-skill`). Run a dry-run scan using the automated cleanup utility:

```bash
dart run .claude/skills/skill-deleter/scripts/delete_skill.dart --name=<skill-name> --dry-run
```

The script locates `.claude/skills/<skill-name>/` and reports all files referencing it (in `lib/`, `test/`, `.claude/`, and `CLAUDE.md`).

### Step 2: Delete Skill Folders
Execute the deletion script:
```bash
dart run .claude/skills/skill-deleter/scripts/delete_skill.dart --name=<skill-name>
```

This automatically:
Deletes `.claude/skills/<skill-name>/`.

### Step 3: Scrub Cross-References
Review the referenced files reported by Step 1:
1. **`CLAUDE.md` and `.claude/rules/`:** Remove skill mentions from rule guidelines.
2. **Other Skills (`SKILL.md`):** Remove dependencies, hub routing rows, links, or checklist items pointing to the deleted skill.
3. **Commands (`.claude/commands/`):** Delete corresponding slash-command files if any existed for this skill.

### Step 4: Verify Quality Gate & Tests
Ensure the removal introduced no breaking changes or broken dependencies:
```bash
dart analyze --fatal-infos
flutter test
```

---

## 3. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Deleting a skill folder without cleaning references in `CLAUDE.md` | **CRITICAL** | A stale pointer is worse than no pointer. Always scrub references immediately. |
| Deleting skills without verifying `dart analyze` passes | **HIGH** | Run static analysis to catch broken code references. |

---

## 4. Verification Checklist

- [ ] Skill directory `.claude/skills/<skill-name>/` deleted.
- [ ] No occurrences of `<skill-name>` remain in `CLAUDE.md` or other skills.
- [ ] `dart analyze --fatal-infos` passes cleanly.
- [ ] `flutter test` passes 100%.
