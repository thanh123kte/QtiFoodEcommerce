import 'package:hive_flutter/hive_flutter.dart';

import '../../models/store_model.dart';

class StoreLocal {
  static const String boxName = 'stores';

  final Box<Map<dynamic, dynamic>> box;

  StoreLocal(this.box);

  Future<void> saveStore(StoreModel store) async {
    await box.put(store.id, store.toJson());
  }

  Future<StoreModel?> getStoreById(int storeId) async {
    final data = box.get(storeId);
    if (data == null) return null;
    return StoreModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<StoreModel?> getStoreByOwner(String ownerId) async {
    for (final key in box.keys) {
      final data = box.get(key);
      if (data == null) continue;
      final map = Map<String, dynamic>.from(data);
      final model = StoreModel.fromJson(map);
      if (model.ownerId == ownerId) return model;
    }
    return null;
  }

  Future<void> removeStore(int storeId) async {
    await box.delete(storeId);
  }

  Future<void> removeStoreByOwner(String ownerId) async {
    for (final key in box.keys) {
      final data = box.get(key);
      if (data == null) continue;
      final map = Map<String, dynamic>.from(data);
      final model = StoreModel.fromJson(map);
      if (model.ownerId == ownerId) {
        await box.delete(key);
      }
    }
  }

  Future<void> removeStoreById(int storeId) async {
    await box.delete(storeId);
  }

  Future<void> clear() async {
    await box.clear();
  }
}
