# Skill Authoring Rules & Invariants

> **Parent Skill:** [skill-creator](../SKILL.md)

---

## 1. Core Authoring Invariants

1. **Progressive Disclosure & The Router Pattern:**
   - Keep the root `SKILL.md` concise and high-signal (target **≤ 100–150 lines**).
   - When a skill grows "thick" (150+ lines or multiple sub-jobs mixed together), convert `SKILL.md` into a **Job Router**:
     * YAML Frontmatter with exhaustive triggers and keywords.
     * High-level architectural overview and non-negotiable constraints.
     * **Job Routing Table** mapping specific scenarios to targeted files in `references/` or `resources/`.
     * Explicit agent directive: *"Read ONLY the referenced file matching your current task; do not load everything at once."*
   - Move extended specifications and annotated code guides into `references/<name>_guide.md`, and config/schema files into `resources/`. Wrapping code samples in markdown reference guides prevents Dart toolchain pollution (e.g. `import_sorter`, `dart analyze`).

2. **Zero-Loss Rule for Refactoring:**
   - When restructuring thick skills, NEVER change what the skill does or drop any triggers, rules, or architectural invariants. Change ONLY the physical organization.

3. **Domain-Agnostic & Abstract Naming Rule (Universal Portability):**
   - ALL code snippets, class names, functions, variables, DTOs, entities, and use cases inside skills MUST use **abstract, domain-agnostic identifiers** (e.g., `[Feature]`, `Item`, `ItemDto`, `ItemEntity`, `User`, `Account`, `Product`, `Resource`, `ExampleItem`) instead of project-specific domain names (e.g., `Movie`, `TMDB`, `CryptoTrade`).
   - This guarantees 100% portability across different codebases without domain residue.

4. **Stale Pointer Policy & Router Synchronization:**
   - *A stale pointer is worse than no pointer.* Whenever a file, skill, example, or folder is moved, renamed, or deleted, update the corresponding router table, Hub routing matrix, and relative markdown links within the **same turn**.
   - Every pointer in a router must resolve to an active, valid file path.

5. **Holistic Tree Audit & De-duplication Rule (Trash & Bloat Pruning):**
   - Whenever skills are created or modified, audit the `.claude/skills/` tree, verify cross-link integrity, and eliminate redundant or duplicate files.
   - **Single Source of Truth:** Never duplicate the same concept across multiple skill folders.
   - **Active Pruning:** Delete obsolete, duplicate, or stale skills (`rm -rf`) to prevent folder bloat.
   - **Banned Dependencies Enforcement:** Strictly enforce project prohibitions in all generated skill code (e.g., ban on `dartz`/`fpdart` `Either`, `provider`, `riverpod`, relative imports, manual copyWith, and hardcoded colors).

6. **Mandatory Post-Creation Audit Gate by `skill-auditor`:**
   - Whenever a skill is created or modified, the agent MUST execute the [`skill-auditor`](../../skill-auditor/SKILL.md) protocol (`/v-audit-skills`).
   - The audit verifies: (a) line count ≤ 120–150 lines, (b) progressive disclosure with `references/` guides, (c) abstract naming with zero domain residue, and (d) zero dead links. Tasks are strictly incomplete without passing this audit gate.

---

## 2. Interlinking & Dependency Standards

1. **Mandatory Relative Paths:**
   - ALWAYS link related and dependent skills using **relative markdown links** (e.g., `[Skill Title](../<sub-skill>/SKILL.md)`).
   - **STRICTLY PROHIBITED:** Using machine-specific absolute paths (`file:///Users/...` or `C:\...`). Relative paths guarantee 100% portability across developer machines, operating systems (macOS/Linux/Windows), and CI/CD environments.

2. **Upstream & Downstream Dependencies:**
   - Child skills must explicitly state upstream dependencies (e.g., "Requires tokens defined in `flutter-ui-theme` before authoring UI components").

3. **Prevent Circular Dependencies & Context Overload:**
   - Do NOT load every child skill simultaneously. Provide clear criteria for when to transition from Hub to Child, or from Child A to Child B.

---

## 3. Anti-Bloat Rule Integration Protocol

When a new skill establishes a project-wide rule, constraint, or invariant (e.g., banning a pattern, enforcing an annotation, setting a file size limit):
1. **DO NOT bloat `CLAUDE.md` directly.**
2. Update or create a focused modular rule file in `.claude/rules/<domain>.md`.
3. Scope the rule with `paths:` frontmatter globs when it only applies to specific files.
4. Ensure `CLAUDE.md` stays under ~200 lines so adherence does not degrade.

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Monolithic `SKILL.md` exceeding 200 lines | **HIGH** | Decompose into Job Router + `references/` via Progressive Disclosure. |
| Hardcoding absolute file paths (`file:///...`) | **CRITICAL** | Use relative markdown links (`../<skill>/SKILL.md`). |
| Using project-specific domain names in skills (`MovieBloc`) | **HIGH** | Use abstract identifiers (`ItemBloc`, `[Feature]State`). |
| Bloating `.claude/CLAUDE.md` with detailed skill rules | **CRITICAL** | Store domain rules in `.claude/rules/<domain>.md`; keep `CLAUDE.md` as a lean index. |
| Stale links or pointers to non-existent files | **HIGH** | Verify and update all relative links within the same turn. |
| Duplicating concepts across multiple skill folders | **HIGH** | Establish a single source of truth; delete or link duplicates. |
