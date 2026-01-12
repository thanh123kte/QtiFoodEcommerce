import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../products/widgets/product_theme.dart';
import '../../../../domain/entities/order.dart';
import 'seller_order_tile.dart';
import 'seller_orders_view_model.dart';

class SellerOrdersScreen extends StatefulWidget {
  final String ownerId;

  const SellerOrdersScreen({super.key, required this.ownerId});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  late final SellerOrdersViewModel _viewModel = GetIt.I<SellerOrdersViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.load(ownerId: widget.ownerId);
    });
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
      child: Scaffold(
        backgroundColor: sellerBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF7A30), Color(0xFFFFA852)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Quản lý đơn hàng',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          Consumer<SellerOrdersViewModel>(
                            builder: (_, vm, __) => Text(
                              vm.storeName ?? 'Đang tải thông tin cửa hàng...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CircleIconButton(
                      icon: Icons.refresh,
                      onTap: () => _viewModel.refresh(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Consumer<SellerOrdersViewModel>(
            builder: (_, vm, __) {
              if (vm.isLoading && vm.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                color: sellerAccent,
                onRefresh: _viewModel.refresh,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _HeaderCard(
                        storeName: vm.storeName,
                        total: vm.countFor('ALL'),
                        statusLabel: _statusLabel(vm.statusFilter),
                      ),
                    ),
                    _StatusFilterBar(
                      selected: vm.statusFilter,
                      onSelected: vm.changeStatusFilter,
                      counts: (key) => vm.countFor(key),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, -2)),
                          ],
                        ),
                        child: _buildBody(vm),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SellerOrdersViewModel vm) {
    if (vm.error != null && vm.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _ErrorState(
            message: vm.error!,
            onRetry: () => _viewModel.load(ownerId: widget.ownerId, refresh: true),
          ),
        ],
      );
    }

    if (!vm.hasStore) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          _ErrorState(
            message: 'Chua tim thay cua hang cua ban. Hay cap nhat thong tin shop.',
            onRetry: null,
          ),
        ],
      );
    }

    if (vm.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 140),
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.orange.shade200),
          const SizedBox(height: 12),
          const Center(child: Text('Chua co don hang nao.')),
          const SizedBox(height: 6),
          const Center(child: Text('Khi co don moi se hien o day.')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemBuilder: (_, index) {
        final order = vm.orders[index];
        return SellerOrderTile(
          order: order,
          onTap: () => _openDetail(order),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: vm.orders.length,
    );
  }

  Future<void> _openDetail(SellerOrderListItem order) async {
    final result = await context.push<Order>(
      '/seller/orders/${order.id}',
      extra: order,
    );
    if (result != null) {
      _viewModel.updateOrder(result);
    }
  }
}

String _statusLabel(String key) {
  switch (key.toUpperCase()) {
    case 'PENDING':
      return 'Mới';
    case 'PREPARING':
      return 'Đang làm';
    case 'SHIPPED':
      return 'Đang giao';
    case 'DELIVERED':
      return 'Hoàn thành';
    case 'CANCELLED':
      return 'Hủy';
    default:
      return 'Tất cả';
  }
}

class _HeaderCard extends StatelessWidget {
  final String? storeName;
  final int total;
  final String statusLabel;

  const _HeaderCard({
    required this.storeName,
    required this.total,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName ?? 'Cửa hàng của bạn',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng $total đơn | Bộ lọc: $statusLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: sellerAccentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: sellerAccent),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final int Function(String key) counts;

  const _StatusFilterBar({
    required this.selected,
    required this.onSelected,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      {'key': 'ALL', 'label': 'Tất cả'},
      {'key': 'PENDING', 'label': 'Mới'},
      {'key': 'PREPARING', 'label': 'Đang làm'},
      {'key': 'PREPARED', 'label': 'Đã sẵn sàng'},
      {'key': 'SHIPPED', 'label': 'Đang giao'},
      {'key': 'DELIVERED', 'label': 'Hoàn thành'},
      {'key': 'CANCELLED', 'label': 'Hủy'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: statuses
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _StatusTab(
                  label: item['label'] as String,
                  count: counts(item['key'] as String),
                  selected: selected == item['key'],
                  onTap: () => onSelected(item['key'] as String),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _StatusTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? sellerAccent : Colors.black87;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label (${count})',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: 42,
              decoration: BoxDecoration(
                color: selected ? sellerAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(onTap == null ? 0.4 : 1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: sellerAccentSoft,
        border: Border.all(color: sellerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: sellerAccent),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: sellerTextMuted)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sellerAccent, foregroundColor: Colors.white),
              onPressed: onRetry,
              child: const Text('Thu lai'),
            ),
          ],
        ],
      ),
    );
  }
}
