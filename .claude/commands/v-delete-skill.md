---
description: Safely delete an agent skill from the repository, and clean cross-references.
---

# /v-delete-skill

Safely delete an agent skill from `.claude/skills/` and scrub cross-references.

## Quick Trigger Guide:
- Runs `dart run .claude/skills/skill-deleter/scripts/delete_skill.dart --name=<skill-name>`.
- Scrubs references from `CLAUDE.md`, rules, and related skills.
- Follows instructions defined in `.claude/skills/skill-deleter/SKILL.md`.
