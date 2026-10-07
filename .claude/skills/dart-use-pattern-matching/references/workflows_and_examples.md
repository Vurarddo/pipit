# Pattern Matching Workflows, Switch Constructs, and Examples

> **Parent Skill:** [dart-use-pattern-matching](../SKILL.md)

This reference provides workflows, switch construct rules, and production examples for pattern matching in Dart.

---

## 1. Switch Statements vs. Expressions

Select the appropriate construct based on the execution context:

* **Producing a Value:** Use a **switch expression**.
  * Syntax: `switch (value) { pattern => expression, }`
  * Rules: Every case must be an expression. No implicit fallthrough. Must be exhaustive.
* **Executing Statements or Side Effects:** Use a **switch statement**.
  * Syntax: `switch (value) { case pattern: statements; }`
  * Rules: Empty cases fall through. Non-empty cases implicitly break (no `break` keyword required).

---

## 2. Exhaustiveness Checking with `sealed` Classes

When switching over `sealed` class hierarchies or enums, Dart verifies at compile-time that all subtypes are covered:

```dart
sealed class const LoadState();

final class const InitialState() extends LoadState;
final class const LoadingState(final double progress) extends LoadState;
final class const SuccessState(final String data) extends LoadState;
final class const ErrorState(final String message) extends LoadState;

// Compile-time exhaustiveness: adding a new subtype forces compiler check
String describeState(LoadState state) => switch (state) {
  InitialState() => 'Idle',
  LoadingState(:var progress) => 'Loading (${(progress * 100).toInt()}%)',
  SuccessState(:var data) => 'Loaded: $data',
  ErrorState(:var message) => 'Failed: $message',
};
```

---

## 3. Production Examples

### JSON Validation & Destructuring
Validate structure and extract values in a single step using `if-case`:

```dart
final payload = {'user': ['Alex', 28]};

if (payload case {'user': [String name, int age]}) {
  print('User $name is $age years old.');
} else {
  print('Invalid payload structure.');
}
```

### Record Destructuring & Swapping
```dart
// Variable swapping without temporary variable
var (a, b) = ('first', 'second');
(b, a) = (a, b);

// Destructuring record returns
final (status, :message) = getOperationStatus();
```

### Guard Clauses (`when`)
Use `when` to evaluate arbitrary boolean conditions after a pattern matches:

```dart
switch (shape) {
  case Square(size: var s) || Circle(size: var s) when s > 0:
    print('Valid symmetric shape with size $s');
  case Square() || Circle():
    print('Empty or invalid zero-sized shape');
  default:
    print('Unknown shape');
}
```
