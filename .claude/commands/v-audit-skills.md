---
description: Run the skill-auditor skill to inspect, refactor, decompose, and optimize agent skills for progressive disclosure and size efficiency.
---

# /v-audit-skills

Invoke the `skill-auditor` skill to audit, refactor, and optimize skills across `.claude/skills/`.

## Quick Trigger Guide:
- Use `/v-audit-skills` (or `/v-refactor-skills`) whenever you need to:
  1. Audit newly created or modified skills against `skill-creator` standards.
  2. Reduce `SKILL.md` line counts (target ≤ 120–150 lines) via Progressive Disclosure.
  3. Extract large code blocks (>30 lines) into `examples/` and config schemas into `resources/`.
  4. Ensure domain-agnostic abstract naming and eliminate dead/broken links.
- Follows instructions defined in `.claude/skills/skill-auditor/SKILL.md`.
