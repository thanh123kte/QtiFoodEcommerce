import 'package:hive_flutter/hive_flutter.dart';

import '../../models/voucher_model.dart';

class VoucherLocal {
  static const String boxName = 'store_vouchers';

  final Box<Map<dynamic, dynamic>> box;

  VoucherLocal(this.box);

  Future<void> saveVouchers(Object storeId, List<VoucherModel> vouchers) async {
    await box.put(
      storeId,
      {
        'vouchers': vouchers.map((e) => e.toJson()).toList(),
      },
    );
  }

  Future<List<VoucherModel>> getVouchers(Object storeId) async {
    final data = box.get(storeId);
    if (data == null) return const [];
    final rawList = data['vouchers'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map>()
        .map((map) => VoucherModel.fromJson(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> upsertVoucher(Object storeId, VoucherModel voucher) async {
    final current = await getVouchers(storeId);
    final updated = <VoucherModel>[
      voucher,
      ...current.where((item) => item.id != voucher.id),
    ];
    await saveVouchers(storeId, updated);
  }

  Future<bool> removeVoucher(int voucherId) async {
    bool removed = false;
    for (final key in box.keys) {
      final current = await getVouchers(key);
      final updated = current.where((item) => item.id != voucherId).toList();
      if (updated.length != current.length) {
        removed = true;
        await saveVouchers(key, updated);
      }
    }
    return removed;
  }

  Future<void> clear(int storeId) => box.delete(storeId);
}
