import 'package:flutter/material.dart';

import '../../../../domain/entities/order.dart';
import '../../../../domain/usecases/order/get_customer_orders.dart';
import '../../../../domain/usecases/store/get_store.dart';

class OrderListViewData {
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

  const OrderListViewData({
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
  });

  Order toOrder() {
    return Order(
      id: id,
      customerId: '',
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

  OrderListViewData copyWith({
    String? storeName,
    String? shippingAddressId,
  }) {
    return OrderListViewData(
      id: id,
      storeId: storeId,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      shippingAddressId: shippingAddressId ?? this.shippingAddressId,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      status: status,
      adminVoucherId: adminVoucherId,
      sellerVoucherId: sellerVoucherId,
      expectedDeliveryTime: expectedDeliveryTime,
      note: note,
      storeName: storeName ?? this.storeName,
    );
  }
}

class OrderListViewModel extends ChangeNotifier {
  final GetCustomerOrders _getCustomerOrders;
  final GetStore _getStore;

  bool _isLoading = false;
  String? _error;
  List<OrderListViewData> _orders = const [];
  List<OrderListViewData> _visible = const [];
  String _statusFilter = 'ALL';
  final Map<int, String> _storeNames = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderListViewData> get orders => List.unmodifiable(_visible);
  String get statusFilter => _statusFilter;

  int countFor(String status) {
    if (status == 'ALL') return _orders.length;
    return _orders.where((order) => _matchesStatus(status, order.status)).length;
  }

  OrderListViewModel(this._getCustomerOrders, this._getStore);

  Future<void> load(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getCustomerOrders(customerId);
    result.when(
      ok: (items) {
        _orders = items.map(_map).toList();
        _error = null;
        _applyFilter();
        _hydrateStoreNames();
      },
      err: (message) {
        _orders = const [];
        _error = message;
        _visible = const [];
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void changeStatusFilter(String status) {
    _statusFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_statusFilter == 'ALL') {
      _visible = _orders;
      return;
    }
    final filter = _statusFilter.toUpperCase();
    _visible = _orders.where((o) => _matchesStatus(filter, o.status)).toList();
  }

  OrderListViewData _map(Order order) {
    return OrderListViewData(
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
      storeName: order.storeName ?? _storeNames[order.storeId],
    );
  }

  Future<void> _hydrateStoreNames() async {
    final ids = _orders.map((o) => o.storeId).toSet();
    for (final id in ids) {
      if (_storeNames.containsKey(id)) continue;
      final result = await _getStore(id);
      result.when(
        ok: (store) {
          _storeNames[id] = store!.name;
        },
        err: (_) {},
      );
    }
    _orders = _orders
        .map((o) => _storeNames[o.storeId] != null ? o.copyWith(storeName: _storeNames[o.storeId]) : o)
        .toList();
    _applyFilter();
    notifyListeners();
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
        return normalized.startsWith('PREPARING') || normalized.startsWith('PREPARE');
      case 'PREPARED':
        return normalized.startsWith('PREPARED') || normalized.startsWith('READY');
      case 'SHIPPED':
        return normalized.startsWith('SHIP') || normalized.startsWith('DELIVERING');
      case 'DELIVERED':
        return normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED');
      case 'REVIEWED':
        return normalized.startsWith('REVIEWED');
      case 'CANCELLED':
        return normalized.startsWith('CANCEL');
      default:
        return normalized.contains(filter);
    }
  }
}
