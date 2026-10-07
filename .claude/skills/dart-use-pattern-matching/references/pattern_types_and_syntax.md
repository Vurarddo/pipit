# Core Pattern Implementations & Selection Strategy

> **Parent Skill:** [dart-use-pattern-matching](../SKILL.md)

This reference outlines the pattern selection strategy and syntax rules for Dart pattern matching.

---

## 1. Pattern Selection Strategy

Apply specific pattern types based on the data structure and desired outcome:

* **Validating and extracting from deserialized data (e.g., JSON):** Use Map and List patterns to simultaneously check structure and destructure key-value pairs.
* **Handling multiple return values:** Use Record patterns to destructure fields directly into local variables.
* **Executing type-specific behavior (Algebraic Data Types):** Use Object patterns combined with `sealed` classes to ensure compile-time exhaustiveness.
* **Matching numeric ranges or conditions:** Use Relational (`>=`, `<=`) and Logical-and (`&&`) patterns.
* **Multiple cases sharing logic:** Use Logical-or (`||`) patterns to share a single case body or guard clause.
* **Ignoring specific values:** Use the Wildcard pattern (`_`) or a non-matching Rest element (`...`) in collections.

---

## 2. Core Pattern Syntax & Implementations

* **Logical-or (`||`):** `pattern1 || pattern2`. Both branches must define the exact same set of variables.
* **Logical-and (`&&`):** `pattern1 && pattern2`. Branches must *not* define overlapping variables.
* **Relational:** `==`, `!=`, `<`, `>`, `<=`, `>=` followed by a constant expression.
* **Cast (`as`):** `pattern as Type`. Throws if the value does not match the type. Use to forcibly assert types during destructuring.
* **Null-check (`?`):** `pattern?`. Fails the match if the value is null. Binds the variable to the non-nullable base type.
* **Null-assert (`!`):** `pattern!`. Throws if the value is null.
* **Variable:** `var name` or `Type name`. Binds the matched value to a new local variable.
* **Wildcard (`_`):** Matches any value and discards it.
* **List:** `[pattern1, pattern2]`. Matches lists of exact length unless a Rest element (`...` or `...var rest`) is used.
* **Map:** `{"key": pattern}`. Matches maps containing the specified keys. Ignores unmatched keys.
* **Record:** `(pattern1, named: pattern2)`. Matches records of the exact shape. Use `:var name` to infer the getter name.
* **Object:** `ClassName(field: pattern)`. Matches instances of `ClassName`. Use `:var field` to infer the getter name.
