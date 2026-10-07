---
name: dart-use-primary-constructors
description: "Modern Dart 3.12+/3.13+ constructors: primary constructors, private named params, super params. Use when creating or refactoring classes, widgets, painters, or value types."
metadata:
  category: dart
---

# Dart Modern Constructors & Class Construction

Use this skill when helping users write, refactor, or debug classes using Dart's modern constructor features: **Private Named Parameters (`this._param`)**, **Super Parameters (`super.param`)**, **Primary Constructors**, and **Concise In-Body Constructors (`new()`)**.

### Dart Version Requirements
- **Dart 3.12+**: Private named parameters (`this._param`) and super parameters enabled by default.
- **Dart 3.13+**: Primary constructors enabled by default.
- **Dart 3.12**: Primary constructors require `--enable-experiment=primary-constructors`.

---

## 1. Overview & Key Benefits

Modern Dart class construction eliminates boilerplate across all architectural layers:
- **Primary Constructors (Dart 3.13+)**: Combines field declaration, parameter declaration, and initialization in the class header (`class Point(var int x, var int y);` or `class const MyWidget({super.key, required final String title}) extends StatelessWidget`).
- **Private Named Parameters (`this._param`)**: Direct initialization of private fields without manual initializer list assignments. Strips leading `_` for callers automatically.
- **Super Parameters (`super.param`)**: Seamless forwarding to superclass constructors (e.g., `super.key` in widgets).
- **Concise In-Body Constructors (`new()`, `new.named()`)**: Omit repetitive class names in secondary and factory constructors.
- **Constructor Tear-Offs**: Pass constructors directly into higher-order methods (`list.map(ItemDto.fromJson)`).

---

## 2. Progressive Disclosure Job Router

> [!IMPORTANT]
> **Read ONLY the referenced document matching your active task.**

| Scenario / Task | Target Reference | Topics Covered |
| :--- | :--- | :--- |
| **Private Named Parameters** | [private_named_parameters.md](references/private_named_parameters.md) | Dart 3.12+ `this._field`, underscore stripping for callers, super parameter interaction, assert scoping, compiler constraints. |
| **Syntax & Scoping Rules** | [syntax_and_scoping.md](references/syntax_and_scoping.md) | Header parameters (`var`/`final`), const constructors, extension types, super params, tear-offs, concise `new()`. |
| **Refactoring Workflows** | [refactoring_workflows.md](references/refactoring_workflows.md) | Migrating verbose private field initializers, subclass super delegation, primary constructors, concise `new()`. |

---

## 3. Core Architectural Invariants

1. **Field-Initializing Private Named Parameters Only:** Named parameters can only be private if they initialize a field: a declaring parameter in a primary constructor (`{required final int _x}`) or an initializing formal in an in-body constructor (`{required this._x}`). Plain private named parameters (`{int _x}`) are strictly prohibited.
2. **Zero Name Collisions:** Neither the private parameter name (`_x`) nor the generated public name (`x`) can conflict with another parameter in the same constructor.
3. **No Secondary Generative Constructors with Primary:** Classes with a primary constructor CANNOT declare additional non-redirecting generative constructors. All in-body generative constructors MUST redirect (`this(...)`).
4. **No Late Parameter Access:** Non-declaring header parameters (no `final`/`var`) CANNOT be referenced inside `late` variable initializers (compile-time error); a declaring parameter is read there as its field.
5. **Zero Double Initialization:** Initializing a field both in the declaration/header and in the body initializer list is a compile-time error.

### Project House Style (matches `lib/`)

- Widgets: `class const DiagnosticsPage({super.key}) extends StatelessWidget {`; a `State` reads `widget.title`.
- Collaborators a class only uses internally are private positional declaring parameters: `class const Spring(final double _stiffness) {`.
- Superclass init, initializer list and constructor body move into the class body: `this : super(const ProjectMemoryState()) { on<Ev>(_onEv); }`.
- An empty class body is `;`. Use `const` only where the constructor could be const. Mutable constructor-initialized fields use `var`.
- Factories (`fromJson`) stay in the body; Freezed classes keep their `const factory Foo(...) = _Foo;` shape.

---

## 4. Diagnostics & Troubleshooting

| Error / Lint Code | Common Cause | Resolution |
| :--- | :--- | :--- |
| `private_named_non_field_parameter` | Using `{int _x}`, which declares no field. | Make it a declaring parameter (`final int _x`) in a primary constructor, or `this._x` in an in-body one. |
| **Parameter name collision** | Declaring both `this._x` and `int x` in the same constructor. | Rename one of the parameters to avoid conflicting public names. |
| **Invalid Public Identifier** | Using `this._` or `this._123`. | Use a valid identifier that forms a valid public name when `_` is removed. |
| **Invalid Late Access** | Accessing a non-declaring primary constructor parameter inside a `late` field initializer. | Make field non-late or pass value through a non-late field. |
| `nonRedirectingGenerativeConstructorWithPrimary` | Non-redirecting in-body constructor declared alongside primary. | Make in-body constructor redirect (e.g. `this(...)`) or remove it. |

---

## 5. Verification Checklist

- [ ] Plain data classes and Value Objects use primary constructors (`class const Point(final int x, final int y);`).
- [ ] Widgets use compact primary constructor syntax with `const` and `super.key` (`class const MyWidget({super.key, required final String title}) extends StatelessWidget`).
- [ ] Private fields are private declaring parameters (`final ApiClient _client`), with zero manual `: _field = field` boilerplate.
- [ ] Subclasses forward to private named parameters using the public argument name (`super.param`).
- [ ] Zero `late` field initializers accessing primary parameters.
- [ ] All in-body generative constructors redirect to the primary one using concise syntax (`new zero() : this(0, 0);`); factories stay in the body.

---

## 6. MCP Dart & Documentation Integration for Agents

When an LLM agent needs to ground itself in official Dart constructor semantics:
- **Official Online Specs:**
  - Primary Constructors: [dart.dev/language/primary-constructors](https://dart.dev/language/primary-constructors)
  - Constructors & Private Formals: [dart.dev/language/constructors](https://dart.dev/language/constructors)
- **Dart MCP Server Tools (`dart-mcp-server`):**
  - Use `lsp` tool for real-time hover, signature inspection, and semantic token resolution on constructors.
  - Use `analyze_files` or `dart analyze` to validate constructor syntax and diagnostics before final commit.
  - Use `dtd` and `hot_reload` to push and test widget/class changes live in running apps.
