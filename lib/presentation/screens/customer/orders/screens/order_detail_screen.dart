import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../order_detail_view_model.dart';
import '../order_list_view_model.dart';
import '../order_tracking_screen.dart';
import '../store_review_screen.dart';
import '../widgets/order_customer_info_card.dart';
import '../widgets/order_detail_header.dart';
import '../widgets/order_items_section.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/order_voucher_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final OrderListViewData? order;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderDetailViewModel _viewModel = GetIt.I<OrderDetailViewModel>();

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    if (order != null) {
      _viewModel.setOrder(order.toOrder());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.loadItems(order.id);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.loadOrderById(widget.orderId);
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showCancelConfirmDialog(BuildContext context, OrderDetailViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể được hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Thoát'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              vm.cancelOrder();
            },
            child: const Text('Hủy đơn hàng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AddressTheme.background,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
            child: Consumer<OrderDetailViewModel>(
              builder: (_, vm, __) {
                final order = vm.order;
                if (vm.isLoading && order == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (order == null) {
                  return Column(
                    children: [
                      const Header(title: 'Chi tiết đơn hàng'),
                      Expanded(
                        child: Center(
                          child: Text(vm.error ?? 'Không tìm thấy đơn hàng'),
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    const Header(title: 'Chi tiết đơn hàng'),
                    const SizedBox(height: 16),
                    OrderDetailHeader(
                      orderId: order.id,
                      storeName: vm.storeName ?? order.storeName ?? '',
                      paymentMethod: order.paymentMethod,
                      createdAt: order.createdAt,
                      expectedDeliveryTime: order.expectedDeliveryTime,
                      status: order.status,
                      note: order.note,
                    ),
                    if (_isShipping(order.status))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.location_on_outlined),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AddressTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderTrackingScreen(orderId: order.id),
                              ),
                            );
                          },
                          label: const Text('Theo dõi đơn hàng'),
                        ),
                      ),
                    if (_isPending(order.status))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.close_outlined),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: vm.isCanceling
                              ? null
                              : () => _showCancelConfirmDialog(context, vm),
                          label: Text(
                            vm.isCanceling ? 'Đang hủy...' : 'Hủy đơn hàng',
                          ),
                        ),
                      ),
                    if (vm.cancelError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vm.cancelError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OrderCustomerInfoCard(vm: vm),
                    const SizedBox(height: 12),
                    OrderVoucherCard(
                      adminVoucherTitle: vm.adminVoucherTitle ?? order.adminVoucherTitle,
                      sellerVoucherTitle: vm.storeVoucherTitle ?? order.sellerVoucherTitle,
                      adminVoucherId: order.adminVoucherId,
                      sellerVoucherId: order.sellerVoucherId,
                      adminVoucherDiscount: order.adminVoucherDiscount,
                      sellerVoucherDiscount: order.sellerVoucherDiscount,
                      totalDiscount: vm.discountAmount,
                      adminVoucherDetail: vm.adminVoucherDetail,
                      sellerVoucherDetail: vm.sellerVoucherDetail,
                    ),
                    const SizedBox(height: 12),
                    OrderItemsSection(vm: vm),
                    const SizedBox(height: 12),
                    OrderSummaryCard(
                      itemsTotal: vm.itemsOriginalTotal,
                      discount: vm.discountAmount,
                      shipping: order.shippingFee,
                      total: order.totalAmount,
                    ),
                    const SizedBox(height: 16),
                    if (_isDelivered(order.status) && !_isReviewed(order.status))
                      ElevatedButton.icon(
                        icon: const Icon(Icons.reviews_outlined),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AddressTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StoreReviewScreen(
                                orderId: order.id,
                                storeId: order.storeId,
                                storeName: vm.storeName ?? order.storeName ?? 'Cửa hàng',
                                storeAddress: vm.address?.address,
                              ),
                            ),
                          );
                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
                            );
                          }
                        },
                        label: const Text('Đánh giá cửa hàng', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

bool _isShipping(String? status) {
  final normalized = (status ?? '').toUpperCase();
  return normalized.startsWith('SHIP') || normalized.startsWith('DELIVERING');
}

bool _isPending(String? status) {
  final normalized = (status ?? '').toUpperCase();
  return normalized.startsWith('PENDING');
}

bool _isDelivered(String? status) {
  final normalized = (status ?? '').toUpperCase();
  return normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED');
}

bool _isReviewed(String? status) {
  final normalized = (status ?? '').toUpperCase();
  return normalized.startsWith('REVIEWED');
}
