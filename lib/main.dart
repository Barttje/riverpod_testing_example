import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MultipleCategorySelection()));
}

final categoryListProvider = StateNotifierProvider((_) => createCategoryList([
      Category("Apple", Colors.red[700]!),
      Category("Orange", Colors.orange[700]!),
      Category("Banana", Colors.yellow[700]!)
    ]));

final selectedCategories = Provider((ref) => ref
    .watch(categoryListProvider)
    .entries
    .where((MapEntry<Category, bool> category) => category.value)
    .map((e) => e.key)
    .toList());

final allCategories =
    Provider((ref) => ref.watch(categoryListProvider).keys.toList());

final selectedCategory = Provider<Category?>((ref) => null);

class MultipleCategorySelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Interactive categories")),
        body: Column(
          children: [
            CategoryFilter(),
            Container(
              color: Colors.green,
              height: 2,
            ),
            SelectedCategories()
          ],
        ),
      ),
    );
  }
}

class CategoryFilter extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryList = ref.watch(selectedCategories);
    final categoryList = ref.watch(allCategories);

    final notifier = ref.watch(categoryListProvider.notifier);
    return Flexible(
      child: ListView.builder(
          itemCount: categoryList.length,
          itemBuilder: (BuildContext context, int index) {
            return CheckboxListTile(
              value: selectedCategoryList.contains(categoryList[index]),
              onChanged: (bool? selected) {
                notifier.toggle(categoryList[index]);
              },
              title: ProviderScope(overrides: [
                selectedCategory.overrideWithValue(categoryList[index])
              ], child: CategoryWidget()),
            );
          }),
    );
  }
}

class SelectedCategories extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryList = ref.watch(selectedCategories);
    return Flexible(
      child: ListView.builder(
          itemCount: categoryList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProviderScope(overrides: [
                  selectedCategory.overrideWithValue(categoryList[index])
                ], child: CategoryWidget()));
          }),
    );
  }
}

class CategoryWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedCategory);
    if (category != null) {
      return Text(
        category.name,
        style: TextStyle(color: category.color),
      );
    }
    return Container();
  }
}

CategoryList createCategoryList(List<Category> values) {
  final Map<Category, bool> categories = Map<Category, bool>();
  values.forEach((value) {
    categories.putIfAbsent(value, () => false);
  });
  return CategoryList(categories);
}

class Category {
  final String name;
  final Color color;

  Category(this.name, this.color);
}

class CategoryList extends StateNotifier<Map<Category, bool>> {
  CategoryList(Map<Category, bool> state) : super(state);

  void toggle(Category item) {
    final currentValue = state[item];
    if (currentValue != null) {
      state[item] = !currentValue;
      state = state;
    }
  }
}
