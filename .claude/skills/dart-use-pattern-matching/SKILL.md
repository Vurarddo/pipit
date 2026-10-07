---
name: dart-use-pattern-matching
description: "Dart 3 switch expressions, destructuring, and sealed-class matching. Use when writing switches, destructuring records or JSON, or adding guard clauses."
metadata:
  category: dart
---

# Dart Pattern Matching & Switch Expressions Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Refactoring verbose chained `if-else` or ternary checks into concise switch expressions.
- Validating and destructuring complex maps, lists, records, or JSON objects (`if-case`).
- Handling exhaustive state machines or sealed class event/state hierarchies.
- Matching value ranges, logical combinations (`||`, `&&`), or relational constraints.
- Applying guard clauses (`when`) to conditional pattern logic.

---

## 2. Progressive Disclosure Job Router

> [!IMPORTANT]
> **Read ONLY the referenced document matching your active task.**

| Scenario / Task | Target Reference | Topics Covered |
| :--- | :--- | :--- |
| **Pattern Types & Syntax** | [pattern_types_and_syntax.md](references/pattern_types_and_syntax.md) | Relational, logical (`||`, `&&`), null-check (`?`), record, map, list, and object patterns. |
| **Workflows & Examples** | [workflows_and_examples.md](references/workflows_and_examples.md) | Switch expressions vs statements, sealed class exhaustiveness, JSON destructuring, `when` guards. |

---

## 3. Core Architectural Invariants

1. **Switch Expressions for Values:** When producing a value or returning from a function, always use a `switch expression` (`switch (x) { pattern => value, }`) rather than a switch statement with local variable mutations.
2. **Compile-Time Exhaustiveness:** Always use `sealed` classes for algebraic data types so the compiler guarantees all subtypes are handled without requiring a fragile wildcard (`_`).
3. **No Redundant Wildcards on Sealed Types:** Do NOT add a fallback `default` or `case _:` when switching over a sealed hierarchy, as it masks compiler warnings when new subtypes are added.
4. **Shared Identifiers in Logical-Or:** Both sides of an `||` pattern must bind the exact same set of variables with identical types.

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Using verbose `switch` statement when returning a value | **MEDIUM** | Convert to concise `switch expression`. |
| Adding `default:` or `_ =>` to sealed class switches | **HIGH** | Remove fallback so missing subtypes trigger compile errors. |
| Deeply nested manual JSON null-checks | **HIGH** | Use `if (json case {'key': [String val]})` pattern destructuring. |
| Inconsistent variable bindings in `pattern1 \|\| pattern2` | **CRITICAL** | Ensure both branches bind identical variable names and types. |

---

## 5. Verification Checklist

When authoring or reviewing pattern matching in Dart:
- [ ] Values are computed via switch expressions.
- [ ] Sealed class switches cover all subtypes without wildcard fallbacks.
- [ ] JSON parsing leverages `if-case` destructuring where appropriate.
- [ ] Guard clauses (`when`) are used for non-pattern boolean conditions.
- [ ] Code passes `dart analyze` with zero exhaustiveness warnings.
