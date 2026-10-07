# Dart Private Named Parameters (`this._field`) Deep-Dive

> **Parent Skill:** [dart-use-primary-constructors](../SKILL.md)  
> **Minimum Dart Version:** **3.12+** (Enabled by default in modern Dart / Flutter)

---

## 1. Overview & Problem Statement

In Dart, any identifier prefixed with an underscore (`_`) is library-private. Prior to Dart 3.12, named parameters could **never** start with an underscore. Consequently, initializing private fields via named parameters required repetitive initializer list boilerplate:

```dart
// ❌ Legacy Verbose Boilerplate (pre-Dart 3.12)
class UserProfile {
  final String _authId;
  final String _email;

  UserProfile({
    required String authId,
    required String email,
  }) : _authId = authId,
       _email = email;
}
```

### The Modern Solution (Dart 3.12+)

Dart 3.12 introduced **Private Named Parameters**. A named parameter may start with `_` when it initializes a field: a declaring parameter in a primary constructor (`final String _authId`, Dart 3.13+, the project standard) or an initializing formal in an in-body constructor (`this._authId`). The compiler initializes the private field while exposing a clean, public identifier to the caller:

```dart
// ✅ Modern Clean Syntax (Dart 3.13+ primary constructor)
class UserProfile({
  required final String _authId,
  required final String _email,
});
```

---

## 2. Call-Site Mechanics: Underscore Stripping

At the call site, the compiler automatically **strips the leading underscore**. Callers always invoke the constructor using the generated public name:

```dart
// At call site:
final profile = UserProfile(
  authId: 'usr_98124', // Uses public name 'authId'
  email: 'dev@example.com',
);

// ❌ COMPILE ERROR: Callers CANNOT use the private name!
// final invalid = UserProfile(_authId: 'usr_98124'); 
```

---

## 3. Parameter Variants: Required, Optional & Defaults

Private named parameters support all standard named parameter semantics:

```dart
class EndpointConfig({
  required final String _baseUrl,                       // Required
  final Duration _timeout = const Duration(seconds: 30), // Optional with default
  final String? _apiKey,                                // Optional nullable
}) {
  String get targetUrl => '$_baseUrl?key=${_apiKey ?? "anonymous"}';
  Duration get timeout => _timeout;
}

// Call site:
final config = EndpointConfig(
  baseUrl: 'https://api.example.com',
  // timeout defaults to 30s, apiKey defaults to null
);
```

---

## 4. Scoping in Initializer Lists & Assertions

When accessing the parameter within the constructor's **initializer list** (`this :` in the body of a primary-constructor class) or inside `assert()` statements, you reference the **private identifier** (`_field`), NOT the public identifier:

```dart
class PositiveRange({
  required final double _min,
  required final double _max,
}) {
  this : assert(_min >= 0, 'min must be positive'),
         assert(_max >= _min, 'max must be greater than or equal to min');
}
```

> [!NOTE]
> Inside the initializer list, `_min` and `_max` refer directly to the parameter values before the instance is fully constructed.

---

## 5. Subclassing & Super Parameter Interaction (`super.param`)

When a subclass forwards parameters to a superclass constructor that uses private named parameters, the subclass **must use the public parameter name** with `super.`:

```dart
// Superclass with private field initialized via named parameter:
class BaseService({required final String _apiKey});

// ✅ Subclass forwards with the public name 'apiKey', NOT '_apiKey':
class AnalyticsService({
  required super.apiKey,
  required final String endpoint,
}) extends BaseService;

// Subclass instantiation:
final service = AnalyticsService(
  apiKey: 'secret_key_123',
  endpoint: 'https://telemetry.example.com',
);
```

---

## 6. Strict Compiler Constraints & Laws

To prevent ambiguity, the Dart compiler enforces strict invariants for private named parameters:

| Constraint | Invalid Example | Explanation / Fix |
| :--- | :--- | :--- |
| **Field-Initializing Parameters Only** | `class Point({required int _x})` | Plain named parameters CANNOT be private (`private_named_non_field_parameter`). Declare the field: `required final int _x` (or `this._x` in an in-body constructor). |
| **No Name Collisions** | `class Point({required final int _x, required int x})` | Neither `_x` nor the generated public name `x` may match another parameter. |
| **Valid Public Identifier** | `class Point({required final int _})` or `{required final int _123}` | Stripping `_` leaves empty string or leading digit, which are illegal Dart identifiers. |
| **No In-Scope Redefinition** | `class Point({required final int _x}) { this : _x = 5; }` | Cannot assign to `_x` in the initializer list if the parameter already initializes it. |

---

## 7. Flutter Widget Use Cases

### 7.1 Encapsulating Widget Callbacks & Configuration (Dart 3.13+ Primary Constructor)
```dart
class const SecureActionButton({
  super.key,
  required final String label,
  required final VoidCallback _onAuthorizedTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onAuthorizedTap,
      child: Text(label),
    );
  }
}
```

### 7.2 Service & Repository Internal Dependencies
```dart
@LazySingleton(as: IUserRepository)
class UserRepositoryImpl(
  final UserApiClient _apiClient,
  final LocalCacheStore _cacheStore,
) implements IUserRepository {
  ...
}
```
Eliminates verbose `: _apiClient = apiClient, _cacheStore = cacheStore;` while preserving strict library encapsulation for internal fields.
