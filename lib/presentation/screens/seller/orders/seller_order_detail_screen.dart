import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/order.dart';
import '../../customer/orders/widgets/order_summary_card.dart';
import '../../customer/orders/widgets/order_voucher_card.dart';
import '../products/widgets/product_theme.dart';
import 'seller_order_detail_view_model.dart';
import 'seller_orders_view_model.dart';
import 'widgets/seller_order_customer_info.dart';
import 'widgets/seller_order_header.dart';
import 'widgets/seller_order_items_section.dart';
import 'widgets/seller_order_status_action.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final SellerOrderListItem? order;

  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
    this.order,
  });

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  late final SellerOrderDetailViewModel _viewModel = GetIt.I<SellerOrderDetailViewModel>();

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    if (order != null) {
      _viewModel.setOrder(order.toOrder());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.loadItems();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.loadById(widget.orderId);
      });
    }
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
      child: Consumer<SellerOrderDetailViewModel>(
        builder: (_, vm, __) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop<Order?>(vm.order);
              return false;
            },
            child: Scaffold(
              backgroundColor: sellerBackground,
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text('Chi tiết đơn hàng'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop<Order?>(_viewModel.order),
                ),
              ),
              body: _buildBody(vm),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(SellerOrderDetailViewModel vm) {
    final order = vm.order;
    if (order == null) {
      if (vm.isLoadingItems) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(child: Text(vm.statusError ?? 'Khong tim thay don hang'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        SellerOrderHeader(order: order),
        const SizedBox(height: 12),
        SellerOrderCustomerInfo(vm: vm),
        const SizedBox(height: 12),
        OrderVoucherCard(
          adminVoucherTitle: vm.adminVoucherTitle,
          sellerVoucherTitle: vm.storeVoucherTitle,
          adminVoucherDiscount: order.adminVoucherDiscount,
          sellerVoucherDiscount: order.sellerVoucherDiscount,
          totalDiscount: vm.discountAmount,
        ),
        const SizedBox(height: 12),
        SellerOrderItemsSection(vm: vm),
        const SizedBox(height: 12),
        OrderSummaryCard(
          itemsTotal: vm.itemsOriginalTotal,
          discount: vm.discountAmount,
          shipping: order.shippingFee,
          total: order.totalAmount,
        ),
        const SizedBox(height: 12),
        SellerOrderStatusAction(vm: vm),
      ],
    );
  }
}
