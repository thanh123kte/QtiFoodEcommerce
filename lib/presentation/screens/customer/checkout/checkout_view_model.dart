import 'package:datn_foodecommerce_flutter_app/utils/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/create_order_input.dart';
import '../../../../domain/entities/shipping_fee.dart';
import '../../../../domain/entities/store.dart';
import '../../../../domain/entities/voucher.dart';
import '../../../../domain/repositories/order_repository.dart';
import '../../../../domain/usecases/address/get_addresses.dart';
import '../../../../domain/usecases/order/create_order.dart';
import '../../../../domain/usecases/order/create_order_item.dart';
import '../../../../domain/usecases/shipping/calculate_shipping_fee.dart';
import '../../../../domain/usecases/store/get_store.dart';
import '../../../../domain/usecases/voucher/get_admin_vouchers.dart';
import '../../../../domain/usecases/voucher/get_store_vouchers.dart';
import '../../../../domain/usecases/voucher/increment_voucher_usage.dart';
import '../../../../domain/usecases/wallet/get_wallet_balance.dart';
import '../cart/cart_sync_notifier.dart';
import '../cart/cart_view_model.dart';
import 'checkout_ui_state.dart';

class CheckoutViewModel extends ChangeNotifier {
  static const double _fallbackShippingFee = 0;

  final String customerId;
  final List<CartItemViewData> items;

  final GetAddresses _getAddresses;
  final GetStoreVouchers _getStoreVouchers;
  final GetAdminVouchers _getAdminVouchers;
  final GetWalletBalance _getWalletBalance;
  final CalculateShippingFee _calculateShippingFee;
  final GetStore _getStore;
  final CreateOrder _createOrder;
  final IncrementVoucherUsage _incrementVoucherUsage;
  final CartSyncNotifier _cartSyncNotifier;
  final FirebaseAuth _auth;

  CheckoutUiState _state = const CheckoutUiState();
  CheckoutUiState get state => _state;

  final Map<int, Store?> _storeCache = {};

  CheckoutViewModel({
    required this.items,
    required this.customerId,
    required GetAddresses getAddresses,
    required GetStoreVouchers getStoreVouchers,
    required GetAdminVouchers getAdminVouchers,
    required GetWalletBalance getWalletBalance,
    required CalculateShippingFee calculateShippingFee,
    required GetStore getStore,
    required CreateOrder createOrder,
    required CreateOrderItem createOrderItem,
    required IncrementVoucherUsage incrementVoucherUsage,
    required CartSyncNotifier cartSyncNotifier,
    required FirebaseAuth auth,
  })  : _getAddresses = getAddresses,
        _getStoreVouchers = getStoreVouchers,
        _getAdminVouchers = getAdminVouchers,
        _getWalletBalance = getWalletBalance,
        _calculateShippingFee = calculateShippingFee,
        _getStore = getStore,
        _createOrder = createOrder,
        _incrementVoucherUsage = incrementVoucherUsage,
        _cartSyncNotifier = cartSyncNotifier,
        _auth = auth {
    _state = _state.copyWith(storeGroups: _buildGroups(items));
  }

  static CheckoutViewModel create({
    required List<CartItemViewData> items,
    required String customerId,
  }) {
    final sl = GetIt.I;
    return CheckoutViewModel(
      items: items,
      customerId: customerId,
      getAddresses: sl<GetAddresses>(),
      getStoreVouchers: sl<GetStoreVouchers>(),
      getAdminVouchers: sl<GetAdminVouchers>(),
      getWalletBalance: sl<GetWalletBalance>(),
      calculateShippingFee: sl<CalculateShippingFee>(),
      getStore: sl<GetStore>(),
      createOrder: sl<CreateOrder>(),
      createOrderItem: sl<CreateOrderItem>(),
      incrementVoucherUsage: sl<IncrementVoucherUsage>(),
      cartSyncNotifier: sl<CartSyncNotifier>(),
      auth: sl<FirebaseAuth>(),
    );
  }

  @override
  void dispose() {
    for (final g in _state.storeGroups) {
      g.dispose();
    }
    super.dispose();
  }

  Future<void> init() async {
    await Future.wait([
      loadAddresses(),
      loadAdminVouchers(),
      loadWalletBalance(),
      loadStoreVouchersForAllStores(),
    ]);
  }

  List<StoreGroupUiModel> _buildGroups(List<CartItemViewData> items) {
    final Map<int, List<CartItemViewData>> grouped = {};
    for (final item in items) {
      final storeId = int.tryParse(item.storeId);
      if (storeId == null) continue;
      grouped.putIfAbsent(storeId, () => []).add(item);
    }
    return grouped.entries
        .map(
          (e) => StoreGroupUiModel(
            storeId: e.key,
            items: e.value,
            shippingFee: 0,
          ),
        )
        .toList();
  }

  Future<void> loadAddresses({bool forceRefresh = false}) async {
    if (customerId.isEmpty) {
      return;
    }
    
    _emit(_state.copyWith(isLoadingAddress: true, addressError: null));
    final result = await _getAddresses(customerId, forceRefresh: forceRefresh);
    
    result.when(
      ok: (addresses) {
        final selected = _resolvePreferredAddress(addresses, _state.selectedAddress);
        _emit(
          _state.copyWith(
            addresses: addresses,
            selectedAddress: selected,
            isLoadingAddress: false,
            addressError: null,
          ),
        );
        updateShippingFees();
      },
      err: (message) {
        _emit(_state.copyWith(isLoadingAddress: false, addressError: message));
      },
    );
  }

  Address? _resolvePreferredAddress(List<Address> addresses, Address? current) {
    if (addresses.isEmpty) return null;
    if (current != null && addresses.any((a) => a.id == current.id)) {
      return current;
    }
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.first;
  }

  Future<void> loadStoreVouchersForAllStores() async {
    final groups = _state.storeGroups;
    for (int i = 0; i < groups.length; i++) {
      await _loadStoreVouchers(groups[i]);
    }
  }

  Future<void> _loadStoreVouchers(StoreGroupUiModel group) async {
    final storeId = group.storeId;
    final currentGroup = _state.storeGroups.firstWhere((g) => g.storeId == storeId);
    _updateGroup(storeId, currentGroup.copyWith(vouchersLoading: true, voucherError: null, vouchers: []));
    
    final result = await _getStoreVouchers(storeId);
    
    result.when(
      ok: (vouchers) {
        final latestGroup = _state.storeGroups.firstWhere((g) => g.storeId == storeId);
        _updateGroup(storeId, latestGroup.copyWith(vouchers: vouchers, vouchersLoading: false, voucherError: null));
      },
      err: (message) {
        final latestGroup = _state.storeGroups.firstWhere((g) => g.storeId == storeId);
        _updateGroup(storeId, latestGroup.copyWith(vouchers: [], vouchersLoading: false, voucherError: message));
      },
    );
  }

  Future<void> loadAdminVouchers() async {
    _emit(_state.copyWith(isLoadingAdminVouchers: true, adminVoucherError: null));
    
    final result = await _getAdminVouchers();
    result.when(
      ok: (vouchers) {
        final adminVouchers = vouchers.where((v) => v.isCreatedByAdmin).toList();
        _emit(
          _state.copyWith(
            adminVouchers: adminVouchers,
            isLoadingAdminVouchers: false,
          ),
        );
      },
      err: (message) {
        _emit(_state.copyWith(isLoadingAdminVouchers: false, adminVoucherError: message));
      },
    );
  }

  Future<void> loadWalletBalance() async {
    final uid = _auth.currentUser?.uid;
    
    if (uid == null) {
      return;
    }
    _emit(_state.copyWith(isLoadingWallet: true));
    
    final result = await _getWalletBalance(uid);
    
    result.when(
      ok: (balance) {
        _emit(_state.copyWith(walletBalance: balance, isLoadingWallet: false));
      },
      err: (message) {
        _emit(_state.copyWith(walletBalance: 0, isLoadingWallet: false));
      },
    );
  }

  void selectAddress(Address address) {
    _emit(_state.copyWith(selectedAddress: address));
    updateShippingFees();
  }

  void selectStoreVoucher(int storeId, Voucher? voucher) {
    final group = _state.storeGroups.firstWhere((g) => g.storeId == storeId);
    _updateGroup(storeId, group.copyWith(selectedVoucher: voucher));
  }

  void selectAdminVoucher(Voucher? voucher) {
    _emit(_state.copyWith(selectedAdminVoucher: voucher));
  }

  void changePaymentMethod(String? value) {
    if (value == null) return;
    if (value == 'QTIWALLET' && !canUseWallet) return;
    _emit(_state.copyWith(paymentMethod: value));
  }

  Future<void> updateShippingFees() async {
    final address = _state.selectedAddress;
    if (_state.storeGroups.isEmpty) return;

    if (address == null || address.latitude == null || address.longitude == null) {
      for (final group in _state.storeGroups) {
        final latest = _state.storeGroups.firstWhere((g) => g.storeId == group.storeId);
        _updateGroup(group.storeId, latest.copyWith(shippingFee: _fallbackShippingFee));
      }
      _emit(_state.copyWith(
        isLoadingShipping: false,
        snackbarMessage: 'Vui long cap nhat dia chi de tinh phi ship.',
      ));
      return;
    }

    _emit(_state.copyWith(isLoadingShipping: true));

    final storeIds = _state.storeGroups.map((g) => g.storeId).toList();
    for (final storeId in storeIds) {
      double fee = _fallbackShippingFee;
      final store = await _getStoreCached(storeId);
      final storeLat = store?.latitude;
      final storeLng = store?.longitude;
      if (storeLat != null && storeLng != null) {
        final result = await _calculateShippingFee(
          storeLat: storeLat,
          storeLng: storeLng,
          recipientLat: address.latitude!,
          recipientLng: address.longitude!,
        );
        result.when(ok: (ShippingFee f) => fee = f.totalFee, err: (_) {});
      }
      final latest = _state.storeGroups.firstWhere((g) => g.storeId == storeId);
      _updateGroup(storeId, latest.copyWith(shippingFee: fee));
    }

    _emit(_state.copyWith(isLoadingShipping: false));
  }
  Future<Store?> _getStoreCached(int storeId) async {
    if (_storeCache.containsKey(storeId)) {
      return _storeCache[storeId];
    }
    final result = await _getStore(storeId);
    Store? store;
    result.when(
      ok: (value) => store = value,
      err: (_) => store = null,
    );
    _storeCache[storeId] = store;
    return store;
  }

  Future<void> placeOrders() async {
    if (_state.isPlacingOrders) {
      return;
    }
    if (_state.storeGroups.isEmpty) {
      _emitSnackbar('Giỏ hàng trống.');
      return;
    }
    
    final address = _state.selectedAddress;
    if (address == null) {
      _emitSnackbar('Vui lòng chọn địa chỉ giao hàng.');
      return;
    }
    
    final addressId = int.tryParse(address.id);
    if (addressId == null) {
      _emitSnackbar('Địa chỉ không hợp lệ, vui lòng chọn lại.');
      return;
    }

  _emit(_state.copyWith(isPlacingOrders: true, orderPlaced: false));

    final adminVoucherId = _state.selectedAdminVoucher?.id;

    try {
      for (final group in _state.storeGroups) {
        final storeId = group.storeId;
        final storePayable = _storePayableAmount(group);
        final storeDiscountAmount = _calculateStoreDiscount(group);
        final adminShare = _calculateAdminDiscountForStore(group, storePayable);
        final shippingFee = group.shippingFee;
        final orderTotal = (storePayable - adminShare + shippingFee).clamp(0, double.infinity);

        final itemsPayload = _buildOrderItemsPayload(
          group: group,
          storeDiscountAmount: storeDiscountAmount,
          storePayable: storePayable,
          adminShare: adminShare,
        );

        final orderInput = CreateOrderInput(
          customerId: customerId,
          storeId: storeId,
          driverId: null,
          shippingAddressId: addressId,
          totalAmount: orderTotal.toDouble(),
          shippingFee: shippingFee.toDouble(),
          adminVoucherId: adminShare > 0 ? adminVoucherId : null,
          sellerVoucherId: group.selectedVoucher?.id,
          paymentMethod: _state.paymentMethod,
          note: group.noteController.text.trim().isEmpty ? null : group.noteController.text.trim(),
          // Send items in create-order payload so BE can compute totals; still persist via bulk API after
          items: itemsPayload,
        );
        final result = await _createOrder(orderInput);

        await result.when(
          ok: (order) async {
            final orderItems = itemsPayload
                .map((item) => CreateOrderItemInput(
                      orderId: order.id,
                      productId: item.productId,
                      quantity: item.quantity,
                      price: item.price,
                    ))
                .toList();

            final bulkResult = await _createOrderItemsBulk(orderItems);
            bulkResult.when(
              ok: (_) => {},
              err: (msg) {
                throw Exception('Failed to create order items: $msg');
              },
            );

            // Increase usage for seller voucher (per store) and admin voucher (per order per store)
            await _incrementVoucherIfAny(group.selectedVoucher?.id);
            await _incrementVoucherIfAny(adminVoucherId);
          },
          err: (message) {
            throw Exception(message);
          },
        );
      }

      _cartSyncNotifier.markDirty(customerId);
      _emit(_state.copyWith(snackbarMessage: 'Đặt hàng thành công', orderPlaced: true));
    } catch (e) {
      _emit(_state.copyWith(snackbarMessage: e.toString()));
    } finally {
      _emit(_state.copyWith(isPlacingOrders: false));
    }
  }

  void clearOrderPlacedFlag() {
    if (_state.orderPlaced) {
      _emit(_state.copyWith(orderPlaced: false));
    }
  }

  Future<void> _incrementVoucherIfAny(int? voucherId) async {
    if (voucherId == null) return;
    await _incrementVoucherUsage(voucherId);
  }

  List<CreateOrderProductInput> _buildOrderItemsPayload({
    required StoreGroupUiModel group,
    required double storeDiscountAmount,
    required double storePayable,
    required double adminShare,
  }) {
    final itemsPayload = <CreateOrderProductInput>[];
    for (final item in group.items) {
      final productId = int.tryParse(item.productId);
      if (productId == null) {
        throw Exception('Sản phẩm không hợp lệ, vui lòng thử lại.');
      }
      itemsPayload.add(
        CreateOrderProductInput(
          productId: productId,
          quantity: item.quantity,
          price: item.unitPrice,
        ),
      );
    }
    return itemsPayload;
  }

  Future<Result<void>> _createOrderItemsBulk(List<CreateOrderItemInput> items) async {
    return GetIt.I<OrderRepository>().createOrderItemsBulk(items);
  }

  double get itemsSubtotal => _state.storeGroups.fold<double>(0, (sum, g) => sum + g.subtotal);

  double _calculateStoreDiscount(StoreGroupUiModel group) {
    final voucher = group.selectedVoucher;
    if (voucher == null) return 0;
    final subtotal = group.subtotal;
    final minOrder = voucher.minOrderValue;
    if (minOrder != null && subtotal < minOrder) return 0;

    double discount;
    switch (voucher.discountType) {
      case VoucherDiscountType.percentage:
        discount = subtotal * (voucher.discountValue / 100);
        final max = voucher.maxDiscount;
        if (max != null && discount > max) discount = max;
        break;
      case VoucherDiscountType.fixedAmount:
      case VoucherDiscountType.unknown:
        discount = voucher.discountValue;
        break;
    }
    if (discount < 0) return 0;
    if (discount > subtotal) return subtotal;
    return discount;
  }

  double get storeDiscountTotal => _state.storeGroups.fold<double>(0, (sum, g) => sum + _calculateStoreDiscount(g));
  double storeDiscountForGroup(StoreGroupUiModel group) => _calculateStoreDiscount(group);

  double _storePayableAmount(StoreGroupUiModel group) {
    final net = group.subtotal - _calculateStoreDiscount(group);
    return net < 0 ? 0 : net;
  }

  double storePayableForGroup(StoreGroupUiModel group) => _storePayableAmount(group);

  double get storePayableTotal => _state.storeGroups.fold<double>(0, (sum, g) => sum + _storePayableAmount(g));

  double _calculateAdminDiscountForStore(StoreGroupUiModel group, double storePayable) {
    final voucher = _state.selectedAdminVoucher;
    if (voucher == null) return 0;
    final minOrder = voucher.minOrderValue;
    if (minOrder != null && storePayable < minOrder) return 0;
    double discount;
    switch (voucher.discountType) {
      case VoucherDiscountType.percentage:
        discount = storePayable * (voucher.discountValue / 100);
        final max = voucher.maxDiscount;
        if (max != null && discount > max) discount = max;
        break;
      case VoucherDiscountType.fixedAmount:
      case VoucherDiscountType.unknown:
        discount = voucher.discountValue;
        break;
    }
    return discount.clamp(0, storePayable);
  }

  double get adminDiscountTotal =>
      _state.storeGroups.fold<double>(0, (sum, g) => sum + _calculateAdminDiscountForStore(g, _storePayableAmount(g)));

  double get shippingTotal => _state.storeGroups.fold<double>(0, (sum, g) => sum + g.shippingFee);

  double get payableAmount => (storePayableTotal - adminDiscountTotal + shippingTotal).clamp(0, double.infinity);

  bool get canUseWallet => !_state.isLoadingWallet && _state.walletBalance >= payableAmount;

  void clearSnackbar() {
    if (_state.snackbarMessage != null) {
      _emit(_state.copyWith(snackbarMessage: null));
    }
  }

  void _updateGroup(int storeId, StoreGroupUiModel newGroup) {
    final updated = _state.storeGroups.map((g) => g.storeId == storeId ? newGroup : g).toList();
    _emit(_state.copyWith(storeGroups: updated));
  }

  void _emit(CheckoutUiState newState) {
    _state = newState;
    notifyListeners();
  }

  void _emitSnackbar(String message) {
    _emit(_state.copyWith(snackbarMessage: message));
  }
}
