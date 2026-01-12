import 'package:flutter/foundation.dart';

import '../../../../domain/entities/cart_item.dart';
import '../../../../domain/usecases/cart/get_cart_items.dart';
import '../../../../domain/usecases/cart/remove_cart_item.dart';
import '../../../../domain/usecases/cart/update_cart_item_quantity.dart';

class CartItemViewData {
  final String id;
  final String productId;
  final String storeId;
  final String name;
  final String? imageUrl;
  final double price;
  final double? discountPrice;
  final int quantity;

  const CartItemViewData({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.name,
    this.imageUrl,
    required this.price,
    this.discountPrice,
    required this.quantity,
  });

  double get unitPrice => discountPrice ?? price;
  double get totalPrice => unitPrice * quantity;

  CartItemViewData copyWith({
    String? id,
    String? productId,
    String? storeId,
    String? name,
    String? imageUrl,
    double? price,
    double? discountPrice,
    int? quantity,
  }) {
    return CartItemViewData(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartViewModel extends ChangeNotifier {
  final GetCartItems _getCartItems;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final RemoveCartItem _removeCartItem;

  CartViewModel(
    this._getCartItems,
    this._updateCartItemQuantity,
    this._removeCartItem,
  );

  final List<CartItemViewData> _items = [];
  final Set<String> _selectedItemIds = <String>{};
  final Set<String> _updatingItemIds = <String>{};
  final Set<String> _removingItemIds = <String>{};

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String? _customerId;

  List<CartItemViewData> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasSelection => _selectedItemIds.isNotEmpty;
  String? get error => _error;
  int get selectedCount => _selectedItemIds.length;
  bool get isEmpty => _items.isEmpty;
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get selectedTotal => _items
      .where((item) => _selectedItemIds.contains(item.id))
      .fold(0.0, (sum, item) => sum + item.totalPrice);
  Set<String> get selectedIds => Set.unmodifiable(_selectedItemIds);
  bool get isRemovingItems => _removingItemIds.isNotEmpty;

  Future<void> load(String customerId, {bool refresh = false, bool forceRemote = true}) async {
    if (_isLoading && !refresh) return;
    _customerId = customerId;
    if (refresh) {
      _isRefreshing = true;
    } else if (!_isLoading) {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();

    final result = await _getCartItems(
      customerId,
      forceRefresh: forceRemote,
    );
    result.when(
      ok: (items) {
        _items
          ..clear()
          ..addAll(items.map(_map));
        _selectedItemIds.removeWhere((id) => _items.every((element) => element.id != id));
      },
      err: (message) {
        _error = message;
      },
    );

    _isLoading = false;
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final id = _customerId;
    if (id == null) return;
    await load(id, refresh: true, forceRemote: true);
  }

  void toggleSelection(String cartItemId) {
    if (_selectedItemIds.contains(cartItemId)) {
      _selectedItemIds.remove(cartItemId);
    } else {
      _selectedItemIds.add(cartItemId);
    }
    notifyListeners();
  }

  void selectAll(bool checked) {
    if (checked) {
      _selectedItemIds
        ..clear()
        ..addAll(_items.map((item) => item.id));
    } else {
      _selectedItemIds.clear();
    }
    notifyListeners();
  }

  bool isSelected(String cartItemId) => _selectedItemIds.contains(cartItemId);

  bool isUpdating(String cartItemId) => _updatingItemIds.contains(cartItemId);

  bool isRemoving(String cartItemId) => _removingItemIds.contains(cartItemId);

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final customerId = _customerId;
    if (customerId == null || quantity <= 0 || _updatingItemIds.contains(cartItemId)) return;
    _updatingItemIds.add(cartItemId);
    notifyListeners();

    final result = await _updateCartItemQuantity(
      customerId: customerId,
      cartItemId: cartItemId,
      quantity: quantity,
    );

    result.when(
      ok: (item) {
        final mapped = _map(item);
        final index = _items.indexWhere((element) => element.id == cartItemId);
        if (index >= 0) {
          _items[index] = mapped;
        }
      },
      err: (message) {
        _error = message;
      },
    );

    _updatingItemIds.remove(cartItemId);
    notifyListeners();
  }

  Future<void> removeItem(String cartItemId) async {
    final customerId = _customerId;
    if (customerId == null || _removingItemIds.contains(cartItemId)) return;
    _removingItemIds.add(cartItemId);
    notifyListeners();

    final result = await _removeCartItem(customerId: customerId, cartItemId: cartItemId);
    result.when(
      ok: (_) {
        _items.removeWhere((element) => element.id == cartItemId);
        _selectedItemIds.remove(cartItemId);
      },
      err: (message) {
        _error = message;
      },
    );

    _removingItemIds.remove(cartItemId);
    notifyListeners();
  }

  Future<void> removeSelectedItems() async {
    if (_selectedItemIds.isEmpty) return;
    final ids = List<String>.from(_selectedItemIds);
    for (final id in ids) {
      await removeItem(id);
    }
  }

  CartItemViewData _map(CartItem item) {
    return CartItemViewData(
      id: item.id,
      productId: item.product.id,
      storeId: item.product.storeId,
      name: item.product.name,
      imageUrl: item.product.imageUrl,
      price: item.product.price,
      discountPrice: item.product.discountPrice,
      quantity: item.quantity,
    );
  }
}
