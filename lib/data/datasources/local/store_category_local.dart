import 'package:hive_flutter/hive_flutter.dart';

import '../../models/store_category_model.dart';

class StoreCategoryLocal {
  static const String boxName = 'store_categories';

  final Box<Map<dynamic, dynamic>> box;

  StoreCategoryLocal(this.box);

  Future<void> saveCategories(int storeId, List<StoreCategoryModel> categories) async {
    final serialized = categories.map((category) => category.toJson()).toList();
    await box.put(storeId, {'items': serialized});
  }

  Future<List<StoreCategoryModel>> getCategories(int storeId) async {
    final data = box.get(storeId);
    if (data == null) return const [];
    final rawList = data['items'] as List<dynamic>? ?? <dynamic>[];
    return rawList
        .whereType<Map>()
        .map((item) => StoreCategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> upsertCategory(StoreCategoryModel category) async {
    final current = await getCategories(category.storeId);
    final updated = <StoreCategoryModel>[
      category,
      ...current.where((item) => item.id != category.id),
    ];
    await saveCategories(category.storeId, updated);
  }

  Future<void> removeCategory(int categoryId) async {
    for (final key in box.keys) {
      final storeId = key as int;
      final categories = await getCategories(storeId);
      if (categories.any((item) => item.id == categoryId)) {
        final updated = categories.where((item) => item.id != categoryId).toList();
        await saveCategories(storeId, updated);
        break;
      }
    }
  }
}
