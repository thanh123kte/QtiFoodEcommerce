import 'package:hive/hive.dart';

import '../../models/cart_item_model.dart';

class CartLocal {
  static const String boxName = 'cart_box';

  final Box<Map<dynamic, dynamic>> box;

  CartLocal(this.box);

  Future<List<CartItemModel>> getCartItems(String customerId) async {
    final raw = box.get(_key(customerId));
    if (raw is Map && raw['items'] is List) {
      return (raw['items'] as List)
          .whereType<Map>()
          .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const [];
  }

  Future<void> saveCartItems(String customerId, List<CartItemModel> items) async {
    await box.put(_key(customerId), {
      'items': items.map((item) => item.toJson()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertCartItem(String customerId, CartItemModel item) async {
    final items = await getCartItems(customerId);
    final index = items.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await saveCartItems(customerId, items);
  }

  Future<void> removeCartItem(String customerId, String cartItemId) async {
    final items = await getCartItems(customerId);
    items.removeWhere((item) => item.id == cartItemId);
    await saveCartItems(customerId, items);
  }

  Future<void> clear(String customerId) async {
    await box.delete(_key(customerId));
  }

  String _key(String customerId) => 'cart_items_$customerId';
}
