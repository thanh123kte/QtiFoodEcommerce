import 'package:flutter/foundation.dart';

import '../../../../domain/entities/order.dart';
import '../../../../domain/usecases/order/get_store_orders.dart';
import '../../../../domain/usecases/store/get_store_by_owner.dart';

class SellerOrderListItem {
  final int id;
  final int storeId;
  final double totalAmount;
  final double shippingFee;
  final String? shippingAddressId;
  final String paymentMethod;
  final DateTime? createdAt;
  final String? status;
  final int? adminVoucherId;
  final int? sellerVoucherId;
  final DateTime? expectedDeliveryTime;
  final String? note;
  final String? storeName;
  final String? customerName;

  const SellerOrderListItem({
    required this.id,
    required this.storeId,
    required this.totalAmount,
    required this.shippingFee,
    this.shippingAddressId,
    required this.paymentMethod,
    this.createdAt,
    this.status,
    this.adminVoucherId,
    this.sellerVoucherId,
    this.expectedDeliveryTime,
    this.note,
    this.storeName,
    this.customerName,
  });

  Order toOrder() {
    return Order(
      id: id,
      customerId: '',
      customerName: customerName,
      storeId: storeId,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      shippingAddressId: shippingAddressId,
      adminVoucherId: adminVoucherId,
      sellerVoucherId: sellerVoucherId,
      paymentMethod: paymentMethod,
      note: note,
      expectedDeliveryTime: expectedDeliveryTime,
      createdAt: createdAt,
      status: status,
      storeName: storeName,
    );
  }
}

class SellerOrdersViewModel extends ChangeNotifier {
  final GetStoreByOwner _getStoreByOwner;
  final GetStoreOrders _getStoreOrders;

  bool _isLoading = false;
  String? _error;
  int? _storeId;
  String? _storeName;
  String? _ownerId;
  List<SellerOrderListItem> _orders = const [];
  List<SellerOrderListItem> _visible = const [];
  String _statusFilter = 'ALL';

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get storeId => _storeId;
  String? get storeName => _storeName;
  bool get hasStore => _storeId != null;
  List<SellerOrderListItem> get orders => List.unmodifiable(_visible);
  String get statusFilter => _statusFilter;
  int countFor(String status) {
    if (status == 'ALL') return _orders.length;
    return _orders.where((order) => _matchesStatus(status, order.status)).length;
  }

  SellerOrdersViewModel(this._getStoreByOwner, this._getStoreOrders);

  Future<void> load({required String ownerId, bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    _ownerId = ownerId;
    _isLoading = true;
    if (!refresh) {
      _error = null;
    }
    notifyListeners();

    int? resolvedStoreId;
    final storeResult = await _getStoreByOwner(ownerId);
    storeResult.when(
      ok: (store) {
        resolvedStoreId = store?.id;
        _storeName = store?.name;
        if (store == null) {
          _error = 'Ban chua co cua hang. Hay hoan tat thong tin shop truoc.';
        }
      },
      err: (message) {
        _error = message;
      },
    );

    if (resolvedStoreId == null) {
      _storeId = null;
      _orders = const [];
      _visible = const [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _storeId = resolvedStoreId;
    final result = await _getStoreOrders(resolvedStoreId!);
    result.when(
      ok: (items) {
        _orders = items.map(_map).toList();
        _error = null;
        _applyFilter();
      },
      err: (message) {
        _orders = const [];
        _visible = const [];
        _error = message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final owner = _ownerId;
    if (owner == null) return;
    await load(ownerId: owner, refresh: true);
  }

  void changeStatusFilter(String status) {
    _statusFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void updateOrder(Order order) {
    final updated = _map(order);
    final exists = _orders.any((item) => item.id == updated.id);
    if (exists) {
      _orders = _orders.map((item) => item.id == updated.id ? updated : item).toList();
    } else {
      _orders = [updated, ..._orders];
    }
    _applyFilter();
    notifyListeners();
  }

  SellerOrderListItem _map(Order order) {
    return SellerOrderListItem(
      id: order.id,
      storeId: order.storeId,
      totalAmount: order.totalAmount,
      shippingFee: order.shippingFee,
      shippingAddressId: order.shippingAddressId,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
      status: order.status,
      adminVoucherId: order.adminVoucherId,
      sellerVoucherId: order.sellerVoucherId,
      expectedDeliveryTime: order.expectedDeliveryTime,
      note: order.note,
      storeName: order.storeName ?? _storeName,
      customerName: order.customerName,
    );
  }

  void _applyFilter() {
    final filter = _statusFilter.toUpperCase();
    if (filter == 'ALL') {
      _visible = _orders;
      return;
    }
    _visible = _orders.where((order) => _matchesStatus(filter, order.status)).toList();
  }

  bool _matchesStatus(String filter, String? status) {
    final normalized = (status ?? '').toUpperCase().trim();
    if (normalized.isEmpty) {
      return filter == 'PENDING';
    }
    if (normalized == filter) return true;
    if (normalized.contains(filter)) return true;
    switch (filter) {
      case 'PENDING':
        return normalized.startsWith('PENDING') ||
            normalized.startsWith('CREATED') ||
            normalized.startsWith('WAIT') ||
            normalized.startsWith('PROCESS') ||
            normalized.startsWith('UNPAID');
      case 'CONFIRMED':
        return normalized.startsWith('CONFIRMED') || normalized.startsWith('ACCEPT');
      case 'PREPARING':
        return normalized.startsWith('PREPARE');
      case 'PREPARED':
        return normalized.startsWith('PREPARED') || normalized.startsWith('READY');
      case 'SHIPPED':
        return normalized.startsWith('SHIP') || normalized.startsWith('DELIVERING');
      case 'DELIVERED':
        return normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED');
      case 'CANCELLED':
        return normalized.startsWith('CANCEL');
      default:
        return normalized.contains(filter);
    }
  }
}
