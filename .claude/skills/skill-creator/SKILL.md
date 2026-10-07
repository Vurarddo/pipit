---
name: skill-creator
description: "Authors and structures agent skills for Claude Code, standalone or hub-and-leaf. Use via /v-skill-creator or when asked to create, refactor, or standardize a skill."
metadata:
  category: skill-management
---

# Claude Code Skill Creator & Standardizer

## 1. Overview & When to Apply

Use this skill whenever:
- Creating a new skill from scratch for Claude Code (`.claude/skills/<name>/SKILL.md`).
- Designing a **Skill Tree / Graph / Mesh** for complex domains (e.g., UI, Networking, State Management) with root coordinators and specialized sub-skills.
- Converting complex workflows, architecture guidelines, or API specifications into modular skills.
- Refactoring, modularizing, or interconnecting existing skills with explicit cross-dependencies.
- Auditing skills for progressive disclosure, frontmatter clarity, and actionable instructions.

---

## 2. Skill vs Rule Decision Matrix

Before creating a skill, determine if a **Skill** is the right customization primitive:

| Need | Use Customization | Location |
| :--- | :--- | :--- |
| **Always-on constraints & guidelines** (e.g., response language, strict layer boundaries, banned packages) | **Modular Rule (`.claude/rules/<domain>.md`)** | `.claude/rules/` (auto-loaded by Claude Code; add `paths:` frontmatter globs to scope a rule to matching files) |
| **On-demand workflow, runbook, or specialized domain knowledge** (e.g., golden tests, procedural characters, release steps) | **Skill (`SKILL.md`)** | `.claude/skills/<name>/` (flat: Claude Code discovers skills only one level deep; group related skills by name prefix and `metadata.category`) |
| **Executable lifecycle hook** (e.g., auto-formatting after edits, pre-commit checks) | **Hook** | `.claude/settings.json` (`hooks`) |
| **External tools, protocol servers, or database connections** | **MCP Server** | `.mcp.json` |

---

## 3. Progressive Disclosure Job Router

> [!IMPORTANT]
> **Read ONLY the referenced document matching your active task.** Do not load all sub-guides simultaneously.

| Scenario / Task | Target Reference | Key Topics Covered |
| :--- | :--- | :--- |
| **Step-by-step creation workflow** | [skill_scaffolding_workflow.md](references/skill_scaffolding_workflow.md) | 6-step authoring workflow from pre-flight audit to anti-bloat sync. |
| **Copy-paste templates** | [skill_templates.md](references/skill_templates.md) | Standard Hub/Coordinator and Leaf/Specialized `SKILL.md` templates. |
| **Architecture & folder organization** | [skill_architecture_types.md](references/skill_architecture_types.md) | Standalone vs Tree/Mesh, Hub roles, and subfolder matrix (`examples/`, `references/`). |
| **Authoring rules & anti-patterns** | [skill_authoring_rules.md](references/skill_authoring_rules.md) | Progressive disclosure, abstract naming, stale pointer policy, anti-patterns table. |

---

## 4. Non-Negotiable Authoring Invariants

1. **Description Budget (Hard Constraint):** Every skill's `description` is loaded into context at session start for ALL skills. Claude Code truncates the combined listing once it grows too large — descriptions past the cut are dropped and those skills can no longer be auto-selected. Keep each `description` to **≈150–200 characters**, and keep the whole tree under **~25,000 characters** (measure: sum of `description` + name over every `SKILL.md`). Write it as `<what it governs>. Use when <concrete triggers>.` — never a feature enumeration.
   > **Where the ~25,000 figure comes from (measured, not documented):** on 2026-09-20 this repo had 136 skills totalling 46.7k characters of descriptions. Everything alphabetically after `flutter-ui-utils-hub` — 50 skills, `git-*` onward — was listed as a bare name with no description and could no longer be auto-selected; only a direct `/name` invocation reached it. The cut sat near 28.6k characters of combined listing. Rewriting all 136 to ~174 characters average (23.7k total) restored the full listing. The published docs mention only a per-skill 1,536-char truncation, so treat ~25k as the working ceiling and re-measure after bulk additions.
2. **Immediate Progressive Disclosure (Target ≤ 100–150 lines):** Keep root `SKILL.md` files lean. If a skill draft exceeds 120–150 lines, decompose it immediately during authoring into a Job Router + `references/` (preferring `.md` guides with code fences over bare code files to avoid Dart toolchain pollution) or `resources/`. Never author or commit a monolithic skill.
3. **Mandatory Post-Creation Audit Gate:** Immediately after authoring or modifying any skill, the agent MUST run the [`skill-auditor`](../skill-auditor/SKILL.md) protocol (`/v-audit-skills`) to verify line count compliance, progressive disclosure, abstract naming, and link integrity.
4. **Relative Markdown Links Only:** ALWAYS link related skills using relative paths (e.g. `[Skill](../<skill>/SKILL.md)`). Machine-specific absolute paths (`file:///...`) are **strictly prohibited**.
5. **Domain-Agnostic Naming:** Code examples, classes, and use cases inside skills MUST use abstract identifiers (`Item`, `User`, `[Feature]`, `Account`) instead of project-specific names (`Movie`, `CryptoTrade`).
6. **Anti-Bloat Rule Sync:** Never bloat `.claude/CLAUDE.md` with detailed skill rules. Store project invariants in `.claude/rules/<domain>.md` and keep `CLAUDE.md` as a lean constitution (target <200 lines).
7. **Stale Pointer Policy:** Every pointer in a router or table must resolve to an active, valid file path within the same turn.

---

## 5. Verification Checklist

When creating or refactoring skills:
- [ ] Frontmatter `name` is kebab-case (≤ 64 chars).
- [ ] Frontmatter has `metadata.category`, reusing an existing category where one fits (the Agentic OS colours and groups skills by it).
- [ ] Frontmatter `description` is ≈150–200 chars and contains explicit "Use when..." activation triggers.
- [ ] Total description budget across `.claude/skills/**/SKILL.md` is still under ~25,000 characters.
- [ ] Relative markdown links are used for all cross-skill navigation (zero `file:///` paths).
- [ ] Progressive disclosure applied immediately: `SKILL.md` is ≤ 120–150 lines and routes to `references/` (as `.md` guides) or `resources/`.
- [ ] Abstract, domain-agnostic identifiers used in all code snippets.
- [ ] Any project-wide invariant is codified in `.claude/rules/<domain>.md`, and `CLAUDE.md` remains lean.
- [ ] Stale or duplicate skill directories are deleted (`rm -rf`).
- [ ] Post-creation verification executed via [`skill-auditor`](../skill-auditor/SKILL.md) protocol (`/v-audit-skills`).
