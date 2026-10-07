# Modern Constructor Refactoring Workflows

> **Parent Skill:** [dart-use-primary-constructors](../SKILL.md)  
> **Related Reference:** [private_named_parameters.md](private_named_parameters.md)

---

## Workflow 1: Migrating Verbose Private Field Initializers to Private Named Parameters

### Problem
Legacy code uses manual assignments in the initializer list to bind named parameters to private fields:

```dart
// ❌ Before: Verbose initializer list boilerplate
class SessionManager {
  final ApiClient _client;
  final SecureStorage _storage;

  SessionManager({
    required ApiClient client,
    required SecureStorage storage,
  }) : _client = client,
       _storage = storage;
}
```

### Refactoring Steps
1. Move each field into the class header as a private declaring parameter (`required final ApiClient _client`) and delete the field declarations.
2. Delete the old constructor with its initializer list assignments (`: _client = client, _storage = storage`).
3. Keep external call sites unchanged (the compiler generates public named arguments automatically).

```dart
// ✅ After: Clean, direct initialization via Primary Constructor (Dart 3.13+)
class SessionManager({
  required final ApiClient _client,
  required final SecureStorage _storage,
});

// Call site unchanged:
final manager = SessionManager(client: apiClient, storage: secureStorage);

// Positional form, as used for injected dependencies (changes call sites):
class SessionManagerPositional(
  final ApiClient _client,
  final SecureStorage _storage,
);
final managerPositional = SessionManagerPositional(apiClient, secureStorage);
```

---

## Workflow 2: Forwarding in Subclasses with Super Parameters

When subclassing a parent class with private named parameters, forward using the **public** argument name via `super.`:

```dart
// Parent class with primary constructor:
abstract class const BaseWidget({
  super.key,
  final EdgeInsets _padding = EdgeInsets.zero,
}) extends StatelessWidget;

// ❌ Before: Explicit manual parameter passing in body
class CustomCard extends BaseWidget {
  const CustomCard({
    super.key,
    EdgeInsets padding = EdgeInsets.zero,
  }) : super(padding: padding);
}

// ✅ After: Direct super parameter forwarding in primary constructor (Dart 3.13+)
class const CustomCard({
  super.key,
  super.padding, // Forwards to public name 'padding'
}) extends BaseWidget {
  @override
  Widget build(BuildContext context) => Padding(padding: _padding);
}
```

---

## Workflow 3: Migrating a Class to a Primary Constructor

1. **Identify Candidate Fields and Constructor:**
   ```dart
   // Before
   class User {
     final String name;
     final int age;
     User(this.name, this.age);
   }
   ```

2. **Move Fields to the Header:**
   ```dart
   // After
   class User(final String name, final int age);
   ```

3. **Handle Custom Initializers and Assertions:**
   ```dart
   // Before
   class Point {
     final int x;
     final int y;
     Point(this.x, this.y) : assert(x >= 0);
   }

   // After
   class Point(final int x, final int y) {
     this : assert(x >= 0);
   }
   ```

4. **Leverage Primary Initializer Scope for Calculations:**
   ```dart
   // Before
   class Rect {
     final double width;
     final double height;
     final double area;
     Rect(this.width, this.height) : area = width * height;
   }

   // After
   class Rect(final double width, final double height) {
     final double area = width * height;
   }
   ```

5. **Convert In-Body Constructors to Redirecting:**
   ```dart
   // Before
   class Point {
     final int x;
     final int y;
     Point(this.x, this.y);
     Point.zero() : x = 0, y = 0;
   }

   // After
   class Point(final int x, final int y) {
     new zero() : this(0, 0); // Redirects to primary
   }
   ```

---

## Workflow 4: Applying Abbreviated (Concise) In-Body Constructors

When a class still needs constructors in its body, use concise syntax; next to a primary constructor every in-body generative constructor must redirect to it, and factories stay as they are:

```dart
// Before
class DatabaseService {
  final String url;
  DatabaseService(this.url);
  DatabaseService.local() : url = 'localhost';
  factory DatabaseService.create() => DatabaseService('default');
}

// After
class DatabaseService(final String url) {
  new local() : this('localhost'); // Redirects to primary
  factory create() => DatabaseService('default');
}
```
