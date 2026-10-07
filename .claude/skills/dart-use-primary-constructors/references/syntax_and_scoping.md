# Dart Modern Constructors Syntax & Scoping Reference

> **Parent Skill:** [dart-use-primary-constructors](../SKILL.md)  
> **Related Reference:** [private_named_parameters.md](private_named_parameters.md)  
> **Official Docs:** [dart.dev/language/primary-constructors](https://dart.dev/language/primary-constructors) | [dart.dev/language/constructors](https://dart.dev/language/constructors)

---

## 1. Syntax Reference

### 1.1 Basic Class Header Syntax (Primary Constructors)
Primary constructors provide a concise way to declare a class's fields and its main constructor in a single line:

```dart
// ❌ Traditional verbose syntax:
// class Point {
//   int x;
//   int y;
//   Point(this.x, this.y);
// }

// ✅ Concise Primary Constructor (Dart 3.13+):
class Point(var int x, var int y);

// Immutable / Constant Primary Constructor:
class const Point(final int x, final int y);
```

### 1.2 Parameter Categories in Primary Constructors
1. **Declaring Parameters**: Indicated by `var` or `final` (e.g., `final int x`). They implicitly create a corresponding instance field in the class.
2. **Initializing Parameters**: Indicated by `this.` or `super.` (e.g., `this.x` or `super.x`). They initialize an existing field or super constructor parameter.
3. **Regular Parameters**: Declared without modifiers (e.g., `int y`). Available only during initialization (in field initializers or `this :` initializer list).

```dart
class C(final int x, int y) extends Base {
  this : super(y);
}
```

### 1.3 Private Named Parameters (Declaring `final _param` & `this._param`) (Dart 3.12+)
Allows initializing private fields using named parameters without manual initializer list assignments. The compiler automatically exposes the public name to callers:

```dart
// ✅ With Primary Constructor (project standard):
class const AuthSession({required final String _token});
class Point({required final double _x, final double _y = 0.0});

// Legacy in-body form (only where a class keeps an in-body constructor):
// class Point {
//   final double _x;
//   final double _y;
//   Point({required this._x, this._y = 0.0});
// }

// Call site uses public names:
final p = Point(x: 10.0, y: 5.0);
final session = AuthSession(token: 'xyz_123');
```

### 1.4 Super Parameters (`super.param`) & Widgets with Primary Constructors
Avoids re-declaring and manually forwarding parameters to superclass constructors. In Flutter widgets (Dart 3.13+), primary constructors make widget definitions extremely compact:

```dart
// ❌ Traditional Verbose Widget:
// class CustomCard extends StatelessWidget {
//   final String title;
//   const CustomCard({super.key, required this.title});
//   @override
//   Widget build(BuildContext context) => Text(title);
// }

// ✅ Compact Modern Widget with Primary Constructor (Dart 3.13+):
class const CustomCard({
  super.key,
  required final String title,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(title);
}
```

### 1.5 Constructor Tear-Offs (`Class.new`, `Class.named`)
Constructors can be passed directly as first-class functions:

```dart
final rawPoints = [[1.0, 2.0], [3.0, 4.0]];

// Default constructor tear-off:
final items = jsonList.map(ItemDto.fromJson).toList();
final points = coordPairs.map(Point.fromCoordinates).toList();
```

### 1.6 Constant Constructors
```dart
// ✅ Primary constructor (project standard):
class const Point(final int x, final int y);

// In-body concise form (only where a primary constructor cannot be used):
class Point {
  final int x;
  final int y;
  const new({required this.x, required this.y});
}
```

### 1.7 Extension Types
Extension types **must** use primary constructors:
- The single parameter in the header is the representation field.
- The representation variable cannot use `var`.
- The representation variable is implicitly `final` if modifier is omitted.

### 1.8 Empty Body Semicolon Shorthand (`;`)
```dart
class C(int x);
mixin class MC;
extension type ET(int x);
mixin M;
extension Ext on C;
```

### 1.9 In-Body Initializer List (`this :`)
```dart
class Point(var int x, int y) {
  final int doubledY;
  this : assert(x >= 0), doubledY = y * 2;
}
```
A declaring parameter (`var int x`) already initializes its field; assigning that field again in `this :` is a compile-time error (`field_initialized_in_parameter_and_initializer`).

### 1.10 Abbreviated Concise Constructor Syntax
For constructors in class bodies, replace the class name with `new` or `factory`:

| Traditional Syntax | Abbreviated Concise Syntax |
| :--- | :--- |
| `MyClass() {}` | `new() {}` |
| `MyClass.name() {}` | `new name() {}` |
| `const MyClass();` | `const new();` |
| `const MyClass.name();` | `const new name();` |
| `factory MyClass() => ...` | `factory() => ...` |
| `factory MyClass.name() => ...` | `factory name() => ...` |

---

## 2. Semantics & Scoping Rules

### 2.1 Primary Initializer Scope
Formal parameters in primary constructors are available to non-late field initializers and `this :` lists:
```dart
class DeltaPoint(final int x, int delta) {
  final int y = x + delta;
}
```

### 2.2 Late Instance Variables Restriction
Primary initializer scope is **not** active for `late` instance variables. Accessing primary constructor parameters in a `late` field initializer causes a compile-time error.

### 2.3 Initializer List Scoping for Private Named Parameters
In initializer lists and assertions, reference the parameter using its **private name** (`_param`), NOT the generated public name:
```dart
class PointAssert({required final double _x}) {
  this : assert(_x >= 0);
}
```

### 2.4 Generative Constructor Restrictions
- Declarations with primary constructors **cannot** declare additional non-redirecting generative constructors.
- All in-body generative constructors **must** redirect to the primary constructor.

---

## 3. Official Documentation & MCP Discovery Guide

When an LLM agent needs to verify or inspect Dart constructor specifications:

1. **Official Ground Truth Links:**
   - Primary Constructors: [dart.dev/language/primary-constructors](https://dart.dev/language/primary-constructors)
   - Constructors & Private Formals: [dart.dev/language/constructors](https://dart.dev/language/constructors)
2. **MCP Tool Verification Protocol:**
   - **`dart-mcp-server`**:
     - `lsp`: Execute language server protocol queries to inspect active types, constructor parameter lists, and diagnostics in live Dart files.
     - `analyze_files`: Run instant static analysis across candidate files to verify primary constructor syntax.
     - `dtd`: Connect to running Dart/Flutter instances for runtime inspection.
   - **`search_web`**: Perform live queries for `site:dart.dev "primary constructors"` or `site:dart.dev "constructors"` when encountering new language version features.
