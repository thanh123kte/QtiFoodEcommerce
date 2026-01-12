import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/orders/widgets/order_ui_parts.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../order_list_view_model.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with WidgetsBindingObserver {
  late final OrderListViewModel _viewModel = GetIt.I<OrderListViewModel>();
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) {
        _viewModel.load(uid);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null) {
      _viewModel.load(uid);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) {
        _viewModel.load(uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<OrderListViewModel>(
        builder: (_, vm, __) {
          final uid = _firebaseAuth.currentUser?.uid;
          final refresh = uid == null ? null : () => _viewModel.load(uid);

          return Scaffold(
            backgroundColor: AddressTheme.background,
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
                child: RefreshIndicator(
                  color: AddressTheme.primary,
                  onRefresh: refresh ?? () async {},
                  child: Column(
                    children: [
                      const Header(title: 'Đơn hàng'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: OrderHeroCard(orderCount: vm.orders.length),
                      ),
                      OrderFilterBar(
                        selected: vm.statusFilter,
                        onSelected: vm.changeStatusFilter,
                        statuses: const [
                          'ALL',
                          'PENDING',
                          'CONFIRMED',
                          'PREPARING',
                          'PREPARED',
                          'SHIPPED',
                          'DELIVERED',
                          'REVIEWED',
                          'CANCELLED',
                        ],
                        counts: (status) => vm.countFor(status),
                      ),
                      Expanded(
                        child: _buildBody(context, vm, refresh),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderListViewModel vm,
    Future<void> Function()? refresh,
  ) {
    if (vm.isLoading) return const OrderSkeletonList();

    if (vm.error != null) {
      return OrderErrorView(
        message: vm.error!,
        onRetry: () {
          final uid = _firebaseAuth.currentUser?.uid;
          if (uid != null) _viewModel.load(uid);
        },
      );
    }

    if (vm.orders.isEmpty) {
      return const OrderEmptyView();
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: vm.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final order = vm.orders[index];
        return _OrderCard(
          order: order,
          onTap: () async {
            await context.push('/orders/${order.id}', extra: order);
            final uid = _firebaseAuth.currentUser?.uid;
            if (uid != null) {
              _viewModel.load(uid);
            }
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderListViewData order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = order.status ?? 'PENDING';
           final statusText = _localizedStatus(status);
    final dateText = order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AddressTheme.border),
          boxShadow: AddressTheme.softShadow,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AddressTheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(Icons.receipt_long, color: _statusColor(status)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn: ${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AddressTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.storeName ?? order.storeId.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AddressTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: order.paymentMethod,
                ),
                if (dateText.isNotEmpty)
                  _InfoRow(
                    icon: Icons.schedule,
                    label: dateText,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(
                    color: AddressTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatCurrency(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AddressTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AddressTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AddressTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  final normalized = status.toUpperCase();
  if (normalized.startsWith('PENDING')) return Colors.orange;
  if (normalized.startsWith('CONFIRMED')) return Colors.blue;
  if (normalized.startsWith('PREPARING')) return Colors.deepPurple;
  if (normalized.startsWith('PREPARED')) return Colors.green;
  if (normalized.startsWith('SHIP')) return Colors.teal;
  if (normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED')) return Colors.teal;
  if (normalized.startsWith('REVIEWED')) return Colors.teal;
  if (normalized.startsWith('CANCEL')) return Colors.redAccent;
  return Colors.grey;
}

String _localizedStatus(String status) {
  final normalized = status.toUpperCase();
  if (normalized.startsWith('PENDING') || normalized.startsWith('WAIT') || normalized.startsWith('UNPAID')) {
    return 'Chờ xử lý';
  }
  if (normalized.startsWith('CONFIRMED') || normalized.startsWith('ACCEPT')) {
    return 'Đã xác nhận';
  }
  if (normalized.startsWith('PREPARING') || normalized.startsWith('PREPARE')) {
    return 'Đang chuẩn bị';
  }
  if (normalized.startsWith('PREPARED') || normalized.startsWith('READY')) {
    return 'Sẵn sàng giao';
  }
  if (normalized.startsWith('SHIP') || normalized.startsWith('DELIVERING')) {
    return 'Đang giao';
  }
  if (normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED')) {
    return 'Đã giao';
  }
  if (normalized.startsWith('REVIEWED')) {
    return 'Đã đánh giá';
  }
  if (normalized.startsWith('CANCEL')) {
    return 'Đã hủy';
  }
  return 'Đang xử lý';
}
