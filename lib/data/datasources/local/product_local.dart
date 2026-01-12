import 'package:hive_flutter/hive_flutter.dart';

import '../../models/product_model.dart';

class ProductLocal {
  static const String boxName = 'store_products';

  final Box<Map<dynamic, dynamic>> box;

  ProductLocal(this.box);

  Future<void> saveProducts(Object storeId, List<ProductModel> products) async {
    final serialized = products.map((product) => product.toJson()).toList();
    await box.put(storeId, {'products': serialized});
  }

  Future<List<ProductModel>> getProducts(Object storeId) async {
    final data = box.get(storeId);
    if (data == null) return const [];
    final rawList = data['products'] as List<dynamic>? ?? <dynamic>[];
    return rawList
        .whereType<Map>()
        .map((map) => ProductModel.fromJson(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> upsertProduct(Object storeId, ProductModel product) async {
    final current = await getProducts(storeId);
    final updated = <ProductModel>[
      product,
      ...current.where((item) => item.id != product.id),
    ];
    await saveProducts(storeId, updated);
  }

  Future<void> removeProduct(Object storeId, String productId) async {
    final current = await getProducts(storeId);
    final updated = current.where((item) => item.id != productId).toList();
    await saveProducts(storeId, updated);
  }

  Future<int?> findStoreIdByProduct(String productId) async {
    for (final key in box.keys) {
      if (key.toString().startsWith('__search__') || key.toString().startsWith('__customer_feed__')) continue;
      final products = await getProducts(key);
      if (products.any((product) => product.id == productId)) {
        if (key is int) return key;
      }
    }
    return null;
  }
}
