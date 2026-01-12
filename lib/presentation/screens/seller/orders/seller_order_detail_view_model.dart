import 'package:flutter/material.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/order_item.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/address/get_address_by_id.dart';
import '../../../../domain/usecases/order/get_order_items.dart';
import '../../../../domain/usecases/order/update_order_status.dart';
import '../../../../domain/usecases/order/get_order_by_id.dart';
import '../../../../domain/usecases/order/assign_driver.dart';
import '../../../../domain/usecases/product/get_store_products.dart';
import '../../../../domain/usecases/voucher/get_admin_vouchers.dart';
import '../../../../domain/usecases/voucher/get_store_vouchers.dart';
import '../../../../utils/result.dart';

class SellerOrderDetailViewModel extends ChangeNotifier {
  final GetOrderItems _getOrderItems;
  final GetProducts _getProducts;
  final GetStoreVouchers _getStoreVouchers;
  final GetAdminVouchers _getAdminVouchers;
  final UpdateOrderStatus _updateOrderStatus;
  final GetAddressById _getAddressById;
  final GetOrderById _getOrderById;
  final AssignDriver _assignDriver;

  Order? _order;
  Address? _address;
  List<OrderItem> _items = const [];
  bool _isLoadingItems = false;
  bool _isLoadingAddress = false;
  bool _isUpdatingStatus = false;
  String? _itemsError;
  String? _addressError;
  String? _statusError;
  String? _adminVoucherTitle;
  String? _storeVoucherTitle;
  bool _driverAssigned = false;

  Order? get order => _order;
  Address? get address => _address;
  List<OrderItem> get items => List.unmodifiable(_items);
  bool get isLoadingItems => _isLoadingItems;
  bool get isLoadingAddress => _isLoadingAddress;
  bool get isUpdatingStatus => _isUpdatingStatus;
  String? get itemsError => _itemsError;
  String? get addressError => _addressError;
  String? get statusError => _statusError;
  String? get adminVoucherTitle => _adminVoucherTitle ?? _order?.adminVoucherTitle;
  String? get storeVoucherTitle => _storeVoucherTitle ?? _order?.sellerVoucherTitle;
  String? get nextStatus => _resolveNextStatus(_order?.status);
  bool get canAdvanceStatus => nextStatus != null && !_isUpdatingStatus;
  bool get canAssignDriver => (_order?.status ?? '').toUpperCase().startsWith('PREPARED') && !_driverAssigned && !_isUpdatingStatus;

  SellerOrderDetailViewModel(
    this._getOrderItems,
    this._getProducts,
    this._getStoreVouchers,
    this._getAdminVouchers,
    this._updateOrderStatus,
    this._getAddressById,
    this._getOrderById,
    this._assignDriver,
  );

  void setOrder(Order order) {
    _order = order;
    _adminVoucherTitle = order.adminVoucherTitle;
    _storeVoucherTitle = order.sellerVoucherTitle;
    _driverAssigned = false;
    notifyListeners();
    _loadVoucherTitles(order.storeId);
    loadAddress();
  }

  Future<void> loadById(String orderId) async {
    _isLoadingItems = true;
    _itemsError = null;
    notifyListeners();

    final parsed = int.tryParse(orderId);
    if (parsed == null) {
      _statusError = 'Mã đơn hàng không hợp lệ';
      _isLoadingItems = false;
      notifyListeners();
      return;
    }
    final result = await _getOrderById(parsed);
    result.when(
      ok: (value) {
        setOrder(value);
      },
      err: (message) {
        _statusError = message;
      },
    );

    if (_order == null) {
      _isLoadingItems = false;
      notifyListeners();
      return;
    }
    await loadItems();
  }

  Future<void> loadItems() async {
    final ord = _order;
    if (ord == null) return;
    _isLoadingItems = true;
    _itemsError = null;
    notifyListeners();
    final Result<List<OrderItem>> result = await _getOrderItems(ord.id);
    result.when(
      ok: (value) {
        _items = value;
        _itemsError = null;
        _hydrateProductInfo();
      },
      err: (message) {
        _items = const [];
        _itemsError = message;
      },
    );
    _isLoadingItems = false;
    notifyListeners();
  }

  Future<void> loadAddress() async {
    final addressId = _order?.shippingAddressId;
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

  double get shippingFee => _order?.shippingFee ?? 30000;

  double get total => _order?.totalAmount ?? (itemsTotal + shippingFee - discountAmount);

  Future<void> advanceStatus() async {
    final ord = _order;
    final next = nextStatus;
    if (ord == null || next == null || next == 'ASSIGN_DRIVER') return;
    _isUpdatingStatus = true;
    _statusError = null;
    notifyListeners();
    final result = await _updateOrderStatus(order: ord, status: next);
    result.when(
      ok: (_) {
        _order = ord.copyWith(status: next);
      },
      err: (message) {
        _statusError = message;
      },
    );
    _isUpdatingStatus = false;
    notifyListeners();
  }

  Future<void> assignDriverNow() async {
    final ord = _order;
    if (ord == null) return;
    _isUpdatingStatus = true;
    _statusError = null;
    notifyListeners();
    final result = await _assignDriver(ord.id);
    result.when(
      ok: (_) {
        _driverAssigned = true;
      },
      err: (message) {
        _statusError = message;
      },
    );
    _isUpdatingStatus = false;
    notifyListeners();
  }

  Future<void> _loadVoucherTitles(int storeId) async {
    final ord = _order;
    if (ord == null) return;

    if (ord.adminVoucherId != null && (_adminVoucherTitle == null || _adminVoucherTitle!.isEmpty)) {
      final result = await _getAdminVouchers();
      result.when(
        ok: (vouchers) {
          for (final voucher in vouchers) {
            if (voucher.id == ord.adminVoucherId) {
              _adminVoucherTitle = voucher.title;
              break;
            }
          }
        },
        err: (_) {},
      );
    }

    if (ord.sellerVoucherId != null && (_storeVoucherTitle == null || _storeVoucherTitle!.isEmpty)) {
      final result = await _getStoreVouchers(storeId);
      result.when(
        ok: (vouchers) {
          for (final voucher in vouchers) {
            if (voucher.id == ord.sellerVoucherId) {
              _storeVoucherTitle = voucher.title;
              break;
            }
          }
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

  String? _resolveNextStatus(String? currentStatus) {
    final normalized = (currentStatus ?? '').toUpperCase().trim();
    if (normalized.isEmpty || normalized.startsWith('PENDING')) return 'CONFIRMED';
    if (normalized.startsWith('CONFIRMED')) return 'PREPARING';
    if (normalized.startsWith('PREPARING')) return 'PREPARED';
    if (normalized.startsWith('PREPARED') && !_driverAssigned) return 'ASSIGN_DRIVER';
    return null;
  }
}
