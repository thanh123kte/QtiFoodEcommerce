import 'package:hive_flutter/hive_flutter.dart';

import '../../models/category_model.dart';

class CategoryLocal {
  static const String boxName = 'categories';
  static const String _keyAll = '__all__';

  final Box<Map<dynamic, dynamic>> box;

  CategoryLocal(this.box);

  Future<void> saveCategories(List<CategoryModel> categories) async {
    final serialized = categories.map((category) => category.toJson()).toList();
    await box.put(_keyAll, {'items': serialized});
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = box.get(_keyAll);
    if (data == null) return const [];
    final rawList = data['items'] as List<dynamic>? ?? <dynamic>[];
    return rawList
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> clear() async {
    await box.delete(_keyAll);
  }
}
