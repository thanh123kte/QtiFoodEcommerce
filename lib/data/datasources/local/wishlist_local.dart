import 'package:hive_flutter/hive_flutter.dart';

import '../../models/store_model.dart';

class WishlistLocal {
  static const String boxName = 'wishlist';

  final Box<Map<dynamic, dynamic>> box;

  WishlistLocal(this.box);

  Future<void> saveStores(String customerId, List<StoreModel> stores) async {
    await box.put(
      customerId,
      {
        'stores': stores.map((e) => e.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<StoreModel>> getStores(String customerId) async {
    final data = box.get(customerId);
    if (data == null) return const [];
    final rawList = data['stores'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map>()
        .map((map) => StoreModel.fromJson(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> clear(String customerId) => box.delete(customerId);
}
