import 'package:flutter/material.dart';

import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/order_item.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/usecases/order/get_order_items.dart';
import '../../../../domain/usecases/order/get_order_by_id.dart';
import '../../../../domain/usecases/order/cancel_order.dart';
import '../../../../domain/usecases/store/get_store.dart';
import '../../../../domain/usecases/voucher/get_store_vouchers.dart';
import '../../../../domain/usecases/voucher/get_admin_vouchers.dart';
import '../../../../domain/usecases/voucher/get_voucher.dart';
import '../../../../domain/usecases/product/get_store_products.dart';
import '../../../../domain/usecases/address/get_address_by_id.dart';
import '../../../../domain/entities/product.dart';
import '../../../../utils/result.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final GetOrderItems _getOrderItems;
  final GetStore _getStore;
  final GetProducts _getProducts;
  final GetStoreVouchers _getStoreVouchers;
  final GetAdminVouchers _getAdminVouchers;
  final GetVoucher _getVoucher;
  final GetAddressById _getAddressById;
  final GetOrderById _getOrderById;
  final CancelOrder _cancelOrder;

  Order? _order;
  List<OrderItem> _items = const [];
  Address? _address;
  bool _isLoading = false;
  bool _isLoadingAddress = false;
  bool _isCanceling = false;
  String? _error;
  String? _addressError;
  String? _cancelError;
  String? _storeName;
  String? _adminVoucherTitle;
  String? _storeVoucherTitle;
  Map<int, Map<String, dynamic>> _adminVoucherDetail = {};
  Map<int, Map<String, dynamic>> _sellerVoucherDetail = {};

  Order? get order => _order;
  List<OrderItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingAddress => _isLoadingAddress;
  bool get isCanceling => _isCanceling;
  String? get error => _error;
  String? get addressError => _addressError;
  String? get cancelError => _cancelError;
  String? get storeName => _order?.storeName ?? _storeName;
  String? get adminVoucherTitle => _adminVoucherTitle ?? _order?.adminVoucherTitle;
  String? get storeVoucherTitle => _storeVoucherTitle ?? _order?.sellerVoucherTitle;
  Address? get address => _address;
  Map<int, Map<String, dynamic>> get adminVoucherDetail => _adminVoucherDetail;
  Map<int, Map<String, dynamic>> get sellerVoucherDetail => _sellerVoucherDetail;

  OrderDetailViewModel(
    this._getOrderItems,
    this._getStore,
    this._getProducts,
    this._getStoreVouchers,
    this._getAdminVouchers,
    this._getVoucher,
    this._getAddressById,
    this._getOrderById,
    this._cancelOrder,
  );

  void setOrder(Order order) {
    _order = order;
    _storeName = order.storeName;
    _adminVoucherTitle = order.adminVoucherTitle;
    _storeVoucherTitle = order.sellerVoucherTitle;
    _loadStoreName(order.storeId);
    _loadVoucherTitles(order.storeId);
    _loadVoucherDetails();
    loadAddress(order.shippingAddressId);
    notifyListeners();
  }

  Future<void> loadOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final parsed = int.tryParse(orderId);
    if (parsed == null) {
      _error = 'Mã đơn hàng không hợp lệ';
      _isLoading = false;
      notifyListeners();
      return;
    }
    final result = await _getOrderById(parsed);
    result.when(
      ok: (value) {
        setOrder(value);
      },
      err: (message) {
        _error = message;
      },
    );

    if (_order != null) {
      await loadItems(_order!.id);
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItems(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final Result<List<OrderItem>> result = await _getOrderItems(orderId);
    result.when(
      ok: (value) {
        _items = value;
        _hydrateProductInfo();
      },
      err: (message) {
        _items = const [];
        _error = message;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAddress(String? addressId) async {
    if (addressId == null || addressId.isEmpty) {
      _address = null;
      _addressError = null;
      notifyListeners();
      return;
    }
    _isLoadingAddress = true;
    _addressError = null;
    notifyListeners();
    final result = await _getAddressById(addressId);
    result.when(
      ok: (value) {
        _address = value;
      },
      err: (message) {
        _address = null;
        _addressError = message;
      },
    );
    _isLoadingAddress = false;
    notifyListeners();
  }

  double get itemsTotal => _items.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get itemsOriginalTotal =>
      _items.fold(0, (sum, item) => sum + (item.originalPrice ?? item.price) * item.quantity);

  double get discountAmount {
    final ord = _order;
    if (ord == null) return 0;
    final diff = itemsOriginalTotal - itemsTotal;
    if (diff > 0) return diff;
    if (ord.adminVoucherDiscount != null || ord.sellerVoucherDiscount != null) {
      final admin = ord.adminVoucherDiscount ?? 0;
      final seller = ord.sellerVoucherDiscount ?? 0;
      return admin + seller;
    }
    final itemsSum = itemsTotal;
    final nonShippingTotal = ord.totalAmount - ord.shippingFee;
    if (itemsSum <= 0 || nonShippingTotal < 0) return 0;
    final discount = itemsSum - nonShippingTotal;
    if (discount <= 0) return 0;
    if (discount > itemsSum) return itemsSum;
    return discount;
  }

  Future<void> _loadVoucherTitles(int storeId) async {
    final ord = _order;
    if (ord == null) return;
    if (ord.adminVoucherId != null && (_adminVoucherTitle == null || _adminVoucherTitle!.isEmpty)) {
      final result = await _getAdminVouchers();
      result.when(
        ok: (vouchers) {
          final found = vouchers.firstWhere(
            (v) => v.id == ord.adminVoucherId,
            orElse: () => ord.adminVoucherTitle != null
                ? vouchers.firstWhere((_) => false, orElse: () => null as dynamic)
                : null as dynamic,
          );
          _adminVoucherTitle = found.title;
                },
        err: (_) {},
      );
    }

    if (ord.sellerVoucherId != null && (_storeVoucherTitle == null || _storeVoucherTitle!.isEmpty)) {
      final result = await _getStoreVouchers(storeId);
      result.when(
        ok: (vouchers) {
          final found = vouchers.firstWhere(
            (v) => v.id == ord.sellerVoucherId,
            orElse: () => null as dynamic,
          );
          _storeVoucherTitle = found.title;
                },
        err: (_) {},
      );
    }
    notifyListeners();
  }

  Future<void> _loadVoucherDetails() async {
    final ord = _order;
    if (ord == null) return;

    if (ord.adminVoucherId != null && !_adminVoucherDetail.containsKey(ord.adminVoucherId)) {
      final result = await _getVoucher(ord.adminVoucherId!);
      result.when(
        ok: (voucher) {
          _adminVoucherDetail[ord.adminVoucherId!] = {
            'code': voucher.code,
            'discountValue': voucher.discountValue,
            'discountType': voucher.discountType,
          };
        },
        err: (_) {},
      );
    }

    if (ord.sellerVoucherId != null && !_sellerVoucherDetail.containsKey(ord.sellerVoucherId)) {
      final result = await _getVoucher(ord.sellerVoucherId!);
      result.when(
        ok: (voucher) {
          _sellerVoucherDetail[ord.sellerVoucherId!] = {
            'code': voucher.code,
            'discountValue': voucher.discountValue,
            'discountType': voucher.discountType,
          };
        },
        err: (_) {},
      );
    }
    notifyListeners();
  }

  Future<void> _hydrateProductInfo() async {
    final ord = _order;
    if (ord == null) return;
    if (_items.every((i) => (i.name ?? '').isNotEmpty && (i.imageUrl ?? '').isNotEmpty && i.originalPrice != null)) {
      return;
    }
    final result = await _getProducts(storeId: ord.storeId, keyword: null);
    result.when(
      ok: (products) {
        final map = {for (final p in products) p.id: p};
        _items = _items.map((item) {
          final product = map[item.productId];
          if (product == null) return item;
          return _mergeItemWithProduct(item, product);
        }).toList();
        notifyListeners();
      },
      err: (_) {},
    );
  }

  OrderItem _mergeItemWithProduct(OrderItem item, Product product) {
    String? imageUrl;
    for (final img in product.images) {
      if (img.isPrimary == true && img.imageUrl.isNotEmpty) {
        imageUrl = img.imageUrl;
        break;
      }
      imageUrl ??= img.imageUrl.isNotEmpty ? img.imageUrl : null;
    }
    return OrderItem(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      quantity: item.quantity,
      price: item.price,
      name: item.name ?? product.name,
      imageUrl: item.imageUrl ?? imageUrl,
      originalPrice: item.originalPrice ?? product.price,
    );
  }

  Future<void> _loadStoreName(int storeId) async {
    if (_storeName != null && _storeName!.isNotEmpty) return;
    final result = await _getStore(storeId);
    result.when(
      ok: (store) {
        _storeName = store?.name;
        notifyListeners();
      },
      err: (_) {},
    );
  }

  Future<void> cancelOrder() async {
    if (_order == null) return;
    _isCanceling = true;
    _cancelError = null;
    notifyListeners();

    final result = await _cancelOrder(_order!);
    result.when(
      ok: (_) {
        _order = _order!.copyWith(status: 'CANCELLED');
        _isCanceling = false;
        _cancelError = null;
        notifyListeners();
      },
      err: (message) {
        _isCanceling = false;
        _cancelError = message;
        notifyListeners();
      },
    );
  }
}
