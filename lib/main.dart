import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MultipleCategorySelection()));
}

final categoryListProvider = StateNotifierProvider((_) => createCategoryList([
      Category("Apple", Colors.red[700]),
      Category("Orange", Colors.orange[700]),
      Category("Banana", Colors.yellow[700])
    ]));

final selectedCategories = Provider((ref) => ref
    .watch(categoryListProvider.state)
    .entries
    .where((category) => category.value)
    .map((e) => e.key)
    .toList());

final allCategories =
    Provider((ref) => ref.watch(categoryListProvider.state).keys.toList());

final selectedCategory = ScopedProvider<Category>(null);

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

class CategoryFilter extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final selectedCategoryList = useProvider(selectedCategories);
    final categoryList = useProvider(allCategories);

    return Flexible(
      child: ListView.builder(
          itemCount: categoryList.length,
          itemBuilder: (BuildContext context, int index) {
            return CheckboxListTile(
              value: selectedCategoryList.contains(categoryList[index]),
              onChanged: (bool selected) {
                context.read(categoryListProvider).toggle(categoryList[index]);
              },
              title: ProviderScope(overrides: [
                selectedCategory.overrideWithValue(categoryList[index])
              ], child: CategoryWidget()),
            );
          }),
    );
  }
}

class SelectedCategories extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final categoryList = useProvider(selectedCategories);
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

class CategoryWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final category = useProvider(selectedCategory);
    return Text(
      category.name,
      style: TextStyle(color: category.color),
    );
  }
}

CategoryList createCategoryList(List<Category> values) {
  final Map<Category, bool> categories = Map();
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
    state[item] = !state[item];
    state = state;
  }
}
