import 'package:flutter/material.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/voucher.dart';
import '../cart/cart_view_model.dart';

class StoreGroupUiModel {
  final int storeId;
  final List<CartItemViewData> items;
  final List<Voucher> vouchers;
  final bool vouchersLoading;
  final String? voucherError;
  final Voucher? selectedVoucher;
  final double shippingFee;
  final TextEditingController noteController;

  StoreGroupUiModel({
    required this.storeId,
    required this.items,
    this.vouchers = const [],
    this.vouchersLoading = false,
    this.voucherError,
    this.selectedVoucher,
    this.shippingFee = 30000,
    TextEditingController? noteController,
  }) : noteController = noteController ?? TextEditingController();

  double get subtotal => items.fold<double>(0, (sum, e) => sum + e.totalPrice);

  StoreGroupUiModel copyWith({
    List<CartItemViewData>? items,
    List<Voucher>? vouchers,
    bool? vouchersLoading,
    String? voucherError,
    Voucher? selectedVoucher,
    double? shippingFee,
    TextEditingController? noteController,
  }) {
    return StoreGroupUiModel(
      storeId: storeId,
      items: items ?? this.items,
      vouchers: vouchers ?? this.vouchers,
      vouchersLoading: vouchersLoading ?? this.vouchersLoading,
      voucherError: voucherError,
      selectedVoucher: selectedVoucher ?? this.selectedVoucher,
      shippingFee: shippingFee ?? this.shippingFee,
      noteController: noteController ?? this.noteController,
    );
  }

  void dispose() {
    noteController.dispose();
  }
}

class CheckoutUiState {
  final List<StoreGroupUiModel> storeGroups;
  final List<Address> addresses;
  final Address? selectedAddress;
  final bool isLoadingAddress;
  final String? addressError;
  final List<Voucher> adminVouchers;
  final Voucher? selectedAdminVoucher;
  final bool isLoadingAdminVouchers;
  final String? adminVoucherError;
  final double walletBalance;
  final bool isLoadingWallet;
  final bool isLoadingShipping;
  final String paymentMethod;
  final bool isPlacingOrders;
  final bool orderPlaced;
  final String? snackbarMessage;

  const CheckoutUiState({
    this.storeGroups = const [],
    this.addresses = const [],
    this.selectedAddress,
    this.isLoadingAddress = false,
    this.addressError,
    this.adminVouchers = const [],
    this.selectedAdminVoucher,
    this.isLoadingAdminVouchers = false,
    this.adminVoucherError,
    this.walletBalance = 0,
    this.isLoadingWallet = false,
    this.isLoadingShipping = false,
    this.paymentMethod = 'COD',
    this.isPlacingOrders = false,
    this.orderPlaced = false,
    this.snackbarMessage,
  });

  CheckoutUiState copyWith({
    List<StoreGroupUiModel>? storeGroups,
    List<Address>? addresses,
    Address? selectedAddress,
    bool? isLoadingAddress,
    String? addressError,
    List<Voucher>? adminVouchers,
    Voucher? selectedAdminVoucher,
    bool? isLoadingAdminVouchers,
    String? adminVoucherError,
    double? walletBalance,
    bool? isLoadingWallet,
    bool? isLoadingShipping,
    String? paymentMethod,
    bool? isPlacingOrders,
    bool? orderPlaced,
    String? snackbarMessage,
  }) {
    return CheckoutUiState(
      storeGroups: storeGroups ?? this.storeGroups,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      addressError: addressError,
      adminVouchers: adminVouchers ?? this.adminVouchers,
      selectedAdminVoucher: selectedAdminVoucher ?? this.selectedAdminVoucher,
      isLoadingAdminVouchers: isLoadingAdminVouchers ?? this.isLoadingAdminVouchers,
      adminVoucherError: adminVoucherError,
      walletBalance: walletBalance ?? this.walletBalance,
      isLoadingWallet: isLoadingWallet ?? this.isLoadingWallet,
      isLoadingShipping: isLoadingShipping ?? this.isLoadingShipping,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPlacingOrders: isPlacingOrders ?? this.isPlacingOrders,
      orderPlaced: orderPlaced ?? this.orderPlaced,
      snackbarMessage: snackbarMessage,
    );
  }
}
