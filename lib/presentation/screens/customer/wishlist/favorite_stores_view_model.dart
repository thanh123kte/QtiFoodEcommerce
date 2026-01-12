import 'package:flutter/material.dart';

import '../../../../domain/entities/store.dart';
import '../../../../domain/usecases/wishlist/get_wishlist_stores.dart';
import '../../../../domain/usecases/wishlist/remove_store_from_wishlist.dart';

class FavoriteStoresViewModel extends ChangeNotifier {
  final GetWishlistStores _getWishlistStores;
  final RemoveStoreFromWishlist _removeStoreFromWishlist;

  bool _isLoading = false;
  String? _error;
  List<Store> _stores = const [];
  final Set<int> _removingStoreIds = {};

  FavoriteStoresViewModel(this._getWishlistStores, this._removeStoreFromWishlist);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Store> get stores => List.unmodifiable(_stores);
  Set<int> get removingStoreIds => _removingStoreIds;

  Future<void> load(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getWishlistStores(customerId: customerId);
    result.when(
      ok: (items) {
        _stores = items;
        _error = null;
      },
      err: (message) {
        _stores = const [];
        _error = message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh(String customerId) => load(customerId);

  Future<bool> remove(String customerId, int storeId) async {
    if (_removingStoreIds.contains(storeId)) return false;
    _removingStoreIds.add(storeId);
    notifyListeners();
    final result = await _removeStoreFromWishlist(customerId: customerId, storeId: storeId);
    bool success = false;
    result.when(
      ok: (_) {
        _stores = _stores.where((store) => store.id != storeId).toList();
        success = true;
      },
      err: (_) {},
    );
    _removingStoreIds.remove(storeId);
    notifyListeners();
    return success;
  }
}
