import 'package:datn_foodecommerce_flutter_app/domain/entities/voucher.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/cart/cart_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/usecases/address/get_address_by_id.dart';
import '../../../../domain/usecases/voucher/get_voucher.dart';
import 'checkout_ui_state.dart';
import 'checkout_view_model.dart';
import 'widgets/address_selection_sheet.dart';
import 'widgets/checkout_header.dart';
import 'widgets/checkout_shipping_section.dart';
import 'widgets/checkout_summary_section.dart';
import 'widgets/payment_method_section.dart';
import 'widgets/platform_voucher_section.dart';
import 'widgets/store_section.dart';
import 'widgets/voucher_sheet.dart';
import '../../seller/products/widgets/product_theme.dart';
import '../addresses/addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemViewData> items;
  final String customerId;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.customerId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutViewModel _viewModel;
  late final GetVoucher _getVoucher = GetIt.I<GetVoucher>();
  late final GetAddressById _getAddressById = GetIt.I<GetAddressById>();

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel.create(items: widget.items, customerId: widget.customerId);
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CheckoutViewModel>(
        builder: (context, vm, _) {
          final state = vm.state;
          _handleSnackBar(context, vm);
          _handleNavigation(context, vm);
          return Scaffold(
            backgroundColor: sellerBackground,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: const Text('Đặt hàng'),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CheckoutHeader(
                  itemCount: widget.items.length,
                  storeCount: state.storeGroups.length,
                  subtotal: vm.itemsSubtotal,
                ),
                const SizedBox(height: 12),
                CheckoutShippingSection(
                  address: state.selectedAddress,
                  hasAddresses: state.addresses.isNotEmpty,
                  isLoading: state.isLoadingAddress,
                  error: state.addressError,
                  onSelect: () => _handleAddressAction(context, vm),
                  onRetry: () => vm.loadAddresses(forceRefresh: true),
                ),
                const SizedBox(height: 16),
                for (final group in state.storeGroups) ...[
                  Builder(
                    builder: (context) {
                      final discount = vm.storeDiscountForGroup(group);
                      final payable = vm.storePayableForGroup(group);
                      return StoreSection(
                        data: group,
                        discountAmount: discount,
                        payableAmount: payable,
                        onVoucherTap: () => _showVoucherSheet(context, vm, group),
                        onReloadVouchers: () => vm.loadStoreVouchersForAllStores(),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                PlatformVoucherSection(
                  selectedVoucher: state.selectedAdminVoucher,
                  totalVouchers: state.adminVouchers.length,
                  isLoading: state.isLoadingAdminVouchers,
                  error: state.adminVoucherError,
                  onTap: () => _showPlatformVoucherSheet(context, vm),
                  onRetry: vm.loadAdminVouchers,
                ),
                const SizedBox(height: 16),
                PaymentMethodSection(
                  paymentMethod: state.paymentMethod,
                  walletBalance: state.walletBalance,
                  walletLoading: state.isLoadingWallet,
                  canUseWallet: vm.canUseWallet,
                  onChanged: vm.changePaymentMethod,
                ),
                const SizedBox(height: 16),
                CheckoutSummarySection(
                  subtotal: vm.itemsSubtotal,
                  storeDiscount: vm.storeDiscountTotal,
                  discountedSubtotal: vm.storePayableTotal,
                  platformDiscount: vm.adminDiscountTotal,
                  shippingFee: vm.shippingTotal,
                  total: vm.payableAmount,
                  platformVoucher: state.selectedAdminVoucher?.code,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sellerAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: state.isPlacingOrders ? null : vm.placeOrders,
                    child: state.isPlacingOrders
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Đặt hàng'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAddressAction(BuildContext context, CheckoutViewModel vm) async {
    final state = vm.state;
    if (state.isLoadingAddress) return;
    if (state.addresses.isEmpty) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()));
      await vm.loadAddresses(forceRefresh: true);
      return;
    }
    final selected = await showModalBottomSheet<Address>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressSelectionSheet(
        addresses: List<Address>.from(state.addresses),
        selectedId: state.selectedAddress?.id,
        onManageTap: () async {
          Navigator.of(ctx).pop();
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()));
          await vm.loadAddresses(forceRefresh: true);
        },
      ),
    );
    if (selected == null) return;
    final isActive = await _ensureAddressActive(selected);
    if (!mounted) return;
    if (!isActive) {
      await vm.loadAddresses(forceRefresh: true);
      return;
    }
    vm.selectAddress(selected);
  }

  Future<void> _showVoucherSheet(
    BuildContext context,
    CheckoutViewModel vm,
    StoreGroupUiModel group,
  ) async {
    final options = group.vouchers
        .map(
          (v) => VoucherOption(
            voucher: v,
            enabled: _isVoucherEnabled(v, group.subtotal),
            message: _voucherMessage(v, group.subtotal),
          ),
        )
        .toList();
    final selected = await showModalBottomSheet<Voucher>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoucherSheet(
        options: options,
        selectedId: group.selectedVoucher?.id,
      ),
    );
    if (selected == null) {
      vm.selectStoreVoucher(group.storeId, null);
      return;
    }
    final isActive = await _ensureVoucherActive(selected, group.subtotal);
    if (!mounted) return;
    if (!isActive) {
      await vm.loadStoreVouchersForAllStores();
      return;
    }
    vm.selectStoreVoucher(group.storeId, selected);
  }

  Future<void> _showPlatformVoucherSheet(BuildContext context, CheckoutViewModel vm) async {
    final state = vm.state;
    if (state.adminVouchers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có voucher sàn khả dụng.')),
      );
      return;
    }
    final options = state.adminVouchers
        .map(
          (v) => VoucherOption(
            voucher: v,
            enabled: _isVoucherEnabled(v, vm.storePayableTotal),
            message: _voucherMessage(v, vm.storePayableTotal),
          ),
        )
        .toList();
    final selected = await showModalBottomSheet<Voucher>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoucherSheet(
        options: options,
        selectedId: state.selectedAdminVoucher?.id,
      ),
    );
    if (selected == null) {
      vm.selectAdminVoucher(null);
      return;
    }
    final isActive = await _ensureVoucherActive(selected, vm.storePayableTotal);
    if (!mounted) return;
    if (!isActive) {
      await vm.loadAdminVouchers();
      return;
    }
    vm.selectAdminVoucher(selected);
  }

  bool _isVoucherEnabled(Voucher voucher, double baseAmount) {
    return _voucherInvalidReason(voucher, baseAmount) == null;
  }

  String? _voucherMessage(Voucher voucher, double baseAmount) {
    return _voucherInvalidReason(voucher, baseAmount);
  }

  String? _voucherInvalidReason(Voucher voucher, double baseAmount) {
    final now = DateTime.now();
    if (!voucher.isActive) return 'Voucher đã tắt';
    switch (voucher.status) {
      case VoucherStatus.active:
        break;
      case VoucherStatus.inactive:
        return 'Voucher tạm ngưng';
      case VoucherStatus.expired:
        return 'Voucher đã hết hạn';
      case VoucherStatus.scheduled:
        return 'Voucher chưa đến thời gian';
      case VoucherStatus.draft:
        return 'Voucher chưa kích hoạt';
      case VoucherStatus.unknown:
        return 'Voucher không hợp lệ';
    }
    if (voucher.startDate != null && now.isBefore(voucher.startDate!)) {
      return 'Voucher chưa đến thời gian';
    }
    if (voucher.endDate != null && now.isAfter(voucher.endDate!)) {
      return 'Voucher đã hết hạn';
    }
    final usageLimit = voucher.usageLimit;
    final usageCount = voucher.usageCount;
    if (usageLimit != null && usageLimit > 0 && usageCount != null && usageCount >= usageLimit) {
      return 'Voucher đã hết lượt sử dụng';
    }
    final minOrder = voucher.minOrderValue;
    if (minOrder != null && baseAmount < minOrder) {
      return 'Đơn tối thiểu ${formatCurrency(minOrder)}';
    }
    return null;
  }

  Future<bool> _ensureVoucherActive(Voucher voucher, double baseAmount) async {
    final result = await _getVoucher(voucher.id);
    bool isActive = false;
    result.when(
      ok: (latest) {
        if (latest.isDeleted == true) {
          _showSnack('Voucher không tồn tại.');
          return;
        }
        final reason = _voucherInvalidReason(latest, baseAmount);
        if (reason != null) {
          _showSnack(reason);
          return;
        }
        isActive = true;
      },
      err: (_) {
        _showSnack('Voucher không tồn tại.');
      },
    );
    return isActive;
  }

  Future<bool> _ensureAddressActive(Address address) async {
    if (address.id.isEmpty) {
      _showSnack('Địa chỉ không tồn tại.');
      return false;
    }
    final result = await _getAddressById(address.id);
    bool isActive = false;
    result.when(
      ok: (latest) {
        if (latest.isDeleted) {
          _showSnack('Địa chỉ không tồn tại.');
          return;
        }
        isActive = true;
      },
      err: (_) {
        _showSnack('Địa chỉ không tồn tại.');
      },
    );
    return isActive;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSnackBar(BuildContext context, CheckoutViewModel vm) {
    final msg = vm.state.snackbarMessage;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        vm.clearSnackbar();
      });
    }
  }

  void _handleNavigation(BuildContext context, CheckoutViewModel vm) {
    if (!vm.state.orderPlaced) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
      vm.clearOrderPlacedFlag();
    });
  }
}
