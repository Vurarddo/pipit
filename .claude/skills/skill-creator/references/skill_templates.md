# Standard `SKILL.md` Templates

> **Parent Skill:** [skill-creator](../SKILL.md)

Use these standard templates when authoring new skills.

---

## 1. Hub / Coordinator Skill Template

```markdown
---
name: <domain>-hub
description: Primary coordinator and architecture guide for <domain>. Use when designing, reviewing, or organizing <domain> features. Routes to specialized sub-skills for <feature-a>, <feature-b>, and <feature-c>.
metadata:
  category: <category>
---

# <Domain Title> Coordinator & Architecture

## 1. Overview & Domain Scope
- High-level domain responsibilities, core philosophy, and foundational principles.

---

## 2. Skill Tree & Routing Matrix

Use this table to navigate to the specialized sub-skill matching your task:

| Task / Sub-Domain | Target Sub-Skill | Purpose |
| :--- | :--- | :--- |
| <Sub-domain task A> | [<domain>-<sub-a>](../<domain>-<sub-a>/SKILL.md) | <What sub-skill A handles> |
| <Sub-domain task B> | [<domain>-<sub-b>](../<domain>-<sub-b>/SKILL.md) | <What sub-skill B handles> |
| <Sub-domain task C> | [<domain>-<sub-c>](../<domain>-<sub-c>/SKILL.md) | <What sub-skill C handles> |

---

## 3. Global Technical Constraints
- Core constraints applicable across all sub-skills in this domain.

---

## 4. Shared Verification Checklist
- [ ] Domain architectural boundaries respected.
- [ ] Appropriate sub-skills invoked for specialized workflows.
```

---

## 2. Specialized / Leaf Skill Template

```markdown
---
name: <domain>-<sub-feature>
description: <What the skill does and exact triggers/keywords for when to activate it.>
metadata:
  category: <category>
---

# <Sub-Feature Title>

## 1. Overview & When to Apply
- Bullet points defining exact scenarios, target directories, file types, or tasks that trigger this skill.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | When to Consult |
| :--- | :--- | :--- |
| **Parent Hub** | [<domain>-hub](../<domain>-hub/SKILL.md) | For global domain rules and routing |
| **Prerequisite** | [<dependency-skill>](../<dependency-skill>/SKILL.md) | If prerequisite models/tokens are missing |
| **Next Step** | [<downstream-skill>](../<downstream-skill>/SKILL.md) | For validation or testing after implementation |

---

## 3. Technical Constraints & Architecture Rules
- Layer boundaries, banned APIs, strict typing rules, performance requirements, or environment constraints.

---

## 4. Standard Implementation Patterns

### 4.1 Pattern A: <Common Use Case>
\`\`\`dart
// Concrete, clean, production-ready code example
\`\`\`

### 4.2 Pattern B: <Advanced / Edge Case>
\`\`\`dart
// Concrete, clean, production-ready code example
\`\`\`

---

## 5. Workflows & Step-by-Step Instructions

### Step 1: <Action>
...

### Step 2: <Action>
...

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| <Banned practice / bug> | **CRITICAL** | <Exact fix> |
| <Suboptimal pattern> | **HIGH** | <Exact fix> |

---

## 7. Agent Verification Checklist

When implementing or reviewing code with this skill:
- [ ] Criterion 1 (e.g., layer separation, naming convention)
- [ ] Criterion 2 (e.g., error handling, type safety)
- [ ] Criterion 3 (e.g., tests and validation steps)
```
