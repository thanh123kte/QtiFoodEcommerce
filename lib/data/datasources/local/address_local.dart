import 'package:hive_flutter/hive_flutter.dart';

import '../../models/address_model.dart';

class AddressLocal {
  static const String boxName = 'user_addresses';

  final Box<Map<dynamic, dynamic>> box;

  AddressLocal(this.box);

  Future<void> saveAddresses(String userId, List<AddressModel> addresses) async {
    final list = addresses.map((e) => e.toJson()).toList();
    await box.put(userId, {'addresses': list});
  }

  Future<List<AddressModel>> getAddresses(String userId) async {
    final data = box.get(userId);
    if (data == null) return const [];
    final rawList = data['addresses'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map>()
        .map((map) => AddressModel.fromJson(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> clear(String userId) async {
    await box.delete(userId);
  }

  Future<bool> removeAddressById(String addressId) async {
    bool removed = false;
    for (final key in box.keys) {
      final data = box.get(key);
      if (data == null) continue;
      final rawList = data['addresses'] as List<dynamic>? ?? [];
      final models = rawList
          .whereType<Map>()
          .map((map) => AddressModel.fromJson(Map<String, dynamic>.from(map)))
          .toList();
      final filtered = models.where((model) => model.id != addressId).toList();
      if (filtered.length != models.length) {
        await box.put(
          key,
          {
            'addresses': filtered.map((model) => model.toJson()).toList(),
          },
        );
        removed = true;
      }
    }
    return removed;
  }

  Future<AddressModel?> findAddressById(String addressId) async {
    for (final key in box.keys) {
      final data = box.get(key);
      if (data == null) continue;
      final rawList = data['addresses'] as List<dynamic>? ?? [];
      for (final raw in rawList) {
        if (raw is Map) {
          final model = AddressModel.fromJson(Map<String, dynamic>.from(raw));
          if (model.id == addressId) return model;
        }
      }
    }
    return null;
  }

  Future<void> upsertAddress(AddressModel model) async {
    final addresses = await getAddresses(model.userId);
    final updated = <AddressModel>[model, ...addresses.where((item) => item.id != model.id)];
    await saveAddresses(model.userId, updated);
  }
}
