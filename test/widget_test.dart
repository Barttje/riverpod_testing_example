import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multiple_category_selection/main.dart';

void main() {
  testWidgets('Simple interaction test without mocking or overriding',
      (tester) async {
    await tester
        .pumpWidget(ProviderScope(child: HookBuilder(builder: (context) {
      return MaterialApp(home: MultipleCategorySelection());
    })));

    var categories = tester.widgetList(find.byType(CategoryWidget));
    expect(categories.length, 3);

    expect((tester.firstWidget(find.byType(Text)) as Text).style!.color,
        Colors.red[700]);
    expect((tester.firstWidget(find.byType(Text)) as Text).data, "Apple");

    var checkboxes = tester.widgetList(find.byType(Checkbox));
    expect(checkboxes.length, 3);

    await tester.tap(find.byWidget(checkboxes.first));
    await tester.pump();

    categories = tester.widgetList(find.byType(CategoryWidget));
    expect(categories.length, 4);

    checkboxes = tester.widgetList(find.byType(Checkbox));
    expect(checkboxes.length, 3);

    await tester.tap(find.byWidget(checkboxes.first));
    await tester.pump();

    categories = tester.widgetList(find.byType(CategoryWidget));
    expect(categories.length, 3);
  });

  testWidgets('Override the current scope', (tester) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          selectedCategory.overrideWithValue(Category("Pear", Colors.green))
        ],
        child: HookBuilder(builder: (context) {
          return MaterialApp(home: CategoryWidget());
        })));

    expect((tester.firstWidget(find.byType(Text)) as Text).style!.color,
        Colors.green);
    expect((tester.firstWidget(find.byType(Text)) as Text).data, "Pear");
  });

  testWidgets('Verify that there is one Category Widget when false',
      (tester) async {
    final state = Map<Category, bool>();
    state.putIfAbsent(Category("Pear", Colors.green), () => false);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          categoryListProvider.overrideWithValue(CategoryList(state)),
        ],
        child: HookBuilder(builder: (context) {
          return MaterialApp(home: MultipleCategorySelection());
        })));

    expect((tester.firstWidget(find.byType(Text)) as Text).style!.color,
        Colors.green);
    expect((tester.firstWidget(find.byType(Text)) as Text).data, "Pear");

    var categories = tester.widgetList(find.byType(CategoryWidget));
    expect(categories.length, 1);
  });

  testWidgets('Verify there are two category widgets', (tester) async {
    final state = Map<Category, bool>();
    state.putIfAbsent(Category("Pear", Colors.green), () => true);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          categoryListProvider.overrideWithValue(CategoryList(state)),
        ],
        child: HookBuilder(builder: (context) {
          return MaterialApp(home: MultipleCategorySelection());
        })));

    expect((tester.firstWidget(find.byType(Checkbox)) as Checkbox).value, true);

    expect((tester.firstWidget(find.byType(Text)) as Text).style!.color,
        Colors.green);
    expect((tester.firstWidget(find.byType(Text)) as Text).data, "Pear");

    var categories = tester.widgetList(find.byType(CategoryWidget));
    expect(categories.length, 2);
  });

  testWidgets('Verify that the toggle is called', (tester) async {
    final state = Map<Category, bool>();
    final category = Category("Pear", Colors.green);
    state.putIfAbsent(category, () => true);
    final mockStateNotifier = CategoryList(state);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          categoryListProvider.overrideWithValue(mockStateNotifier),
        ],
        child: HookBuilder(builder: (context) {
          return MaterialApp(home: MultipleCategorySelection());
        })));

    var checkbox = tester.widgetList(find.byType(Checkbox));
    await tester.tap(find.byWidget(checkbox.first));
    await tester.pump();

    expect(mockStateNotifier.state[category], false);
  });
}
