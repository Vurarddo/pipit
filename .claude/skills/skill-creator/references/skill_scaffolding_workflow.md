# Step-by-Step Skill Creation & Scaffolding Workflow

> **Parent Skill:** [skill-creator](../SKILL.md)

Follow this 6-step workflow when creating new skills or building modular skill trees:

---

## Step 1: Pre-Flight Audit & Duplicate Detection

1. **Search Existing Skills:** Inspect `.claude/skills/` to identify existing skills covering the target domain.
2. **Identify Duplication:** If similar skills exist, decide whether to refactor/extend them or replace them with a modular tree. Avoid creating overlapping duplicate skills.

---

## Step 2: Scope & Hierarchy Planning

1. Determine if the task needs a **Single Standalone Skill** or a **Skill Tree/Mesh**.
2. If building a tree/mesh:
   - Identify the **Domain Root (Hub)**.
   - List distinct **Sub-Skills (Leaves)** and map inter-dependencies (upstream/downstream).
   - Identify cross-cutting **Utility Skills** needed.

---

## Step 3: Scaffold Skill Folder Structure

- **Standalone Skill:** Create `.claude/skills/<skill-name>/` with `SKILL.md` (and optional `examples/`, `references/`, `resources/`).
- **Skill Tree:** Create flat sibling folders `.claude/skills/<domain>-hub/` and `.claude/skills/<domain>-<sub-feature>/` (Claude Code does not discover nested skill folders). Add `metadata:\n  category: <domain>` to each `SKILL.md` frontmatter.

---

## Step 4: Author Content with Interlinking

1. Draft YAML frontmatters with clear triggers and hierarchical context.
2. Fill Hub skills with domain routing tables and global constraints.
3. Fill Child skills with actionable recipes, code patterns, and prerequisite links.
4. Establish clear markdown file links between related skills using relative paths.

---

## Step 5: Post-Flight De-Duplication, Pruning & Mesh Validation

1. **Prune Stale & Duplicate Files:** Delete old monolithic or redundant skill directories (`rm -rf`) that are superseded by the new tree.
2. **Sync Cross-Links:** Update parent hubs, `flutter-clean-architecture`, and adjacent layer hubs so all relative markdown links point to active, valid files.

---

## Step 6: Rule System Sync & Anti-Bloat Verification

1. **Check for New Project Invariants:** If the new skill establishes a project-wide rule, constraint, or invariant:
   - **DO NOT bloat `CLAUDE.md` directly.**
   - Update or create a focused modular rule file in `.claude/rules/<domain>.md`.
   - Scope the rule with `paths:` frontmatter globs when it only applies to specific files.
   - Ensure `CLAUDE.md` stays under ~200 lines so adherence does not degrade.

---

## Step 7: Mandatory Skill Auditor Verification (`/v-audit-skills`)

1. **Execute Audit:** Immediately run the [`skill-auditor`](../../skill-auditor/SKILL.md) protocol against every created or modified skill.
2. **Enforce Size Ceiling:** Ensure `SKILL.md` is strictly ≤ 120–150 lines. If larger, extract content into `references/` or `examples/` immediately.
3. **Verify Integrity:** Validate abstract identifiers (`[Feature]`, `Item`), check for domain residue, and confirm all relative links point to active files.

