# Golden Test Workflow

---

## 1. A Golden Test

```dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, theme) in [('light', AppTheme.lightTheme), ('dark', AppTheme.darkTheme)]) {
    testWidgets('an item card looks as agreed, $name', (tester) async {
      tester.view
        ..physicalSize = const Size(600, 300)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const subject = ValueKey('golden');
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Center(
            child: RepaintBoundary(key: subject, child: const ItemCard(title: 'Item')),
          ),
        ),
      );
      await expectLater(find.byKey(subject), matchesGoldenFile('goldens/item/item_card_$name.png'));
    });
  }
}
```

The path is relative to the test file.

## 2. Tolerance for Anti-Aliasing

The default comparator demands identical bytes. A comparator that accepts a tiny fraction of
differing pixels keeps goldens stable across GPU and OS updates on the same platform. Install it
from a `flutter_test_config.dart` in the goldens folder: Flutter runs that file's
`testExecutable` around every test in the folder, so no test imports it (and no relative import is
needed).

```dart
// test/goldens/flutter_test_config.dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(current.basedir.resolve('golden_test.dart'), 0.0001);
  }
  await testMain();
}

class _TolerantComparator(super.testFile, final double _tolerance) extends LocalFileComparator {
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= _tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
```

`diffPercent` is a fraction of all pixels (0.0001 = 0.01 %). It is measured over the whole image,
so a small change in a big image is a tiny fraction: a 6 px wider accessory on a 290×650 golden
changed 0.47 % and passed a 0.5 % tolerance unnoticed. Check the tolerance the way it will fail:
make one deliberate small change, see the golden fail, revert it. The comparator resolves goldens
next to the folder's tests, so keep golden tests directly in that folder.

## 3. Running and Updating

```bash
flutter test --tags golden                   # only the goldens
flutter test --tags golden --update-goldens  # accept intended changes
```

Declare the tag once in `dart_test.yaml` (`tags: {golden: {}}`) so the runner knows it.

## 4. Reading a Failure

A failing golden writes `test/goldens/<area>/failures/`: the master, the test image, and masked
and isolated diffs. Open them; if the change is intended, update and commit the new PNGs with the
code that changed them, and say so in the commit. Keep `failures/` out of git.
