import 'package:flutter/material.dart';

import '../../addresses/widgets/address_theme.dart';

class OrderHeroCard extends StatelessWidget {
  final int orderCount;

  const OrderHeroCard({super.key, required this.orderCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7EE), Color(0xFFFFE9D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AddressTheme.primary.withOpacity(0.12),
            ),
            child: const Icon(Icons.receipt_long, color: AddressTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn hàng của tôi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AddressTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  orderCount > 0
                      ? 'Bạn có $orderCount đơn hàng đã đặt.'
                      : 'Theo dõi trạng thái và lịch sử đặt mua của bạn.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AddressTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AddressTheme.badge,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AddressTheme.border),
            ),
            child: Text(
              '$orderCount',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AddressTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> statuses;
  final int Function(String status)? counts;

  const OrderFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.statuses,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final statusMap = const {
      'ALL': 'Tất cả',
      'PENDING': 'Mới',
      'CONFIRMED': 'Xác nhận',
      'PREPARING': 'Đang làm',
      'PREPARED': 'Đã sẵn sàng',
      'SHIPPED': 'Đang giao',
      'DELIVERED': 'Hoàn thành',
      'REVIEWED': 'Đã đánh giá',
      'CANCELLED': 'Hủy',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: statuses
            .map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _StatusFilterTab(
                  label: statusMap[status] ?? status,
                  count: counts?.call(status) ?? 0,
                  selected: selected == status,
                  onTap: () => onSelected(status),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatusFilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AddressTheme.primary : Colors.black87;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ($count)',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 24,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderEmptyView extends StatelessWidget {
  const OrderEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AddressTheme.border),
            boxShadow: AddressTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AddressTheme.primary.withOpacity(0.08),
                ),
                child: const Icon(Icons.inbox_outlined, size: 40, color: AddressTheme.primary),
              ),
              const SizedBox(height: 14),
              const Text(
                'Chưa có đơn hàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AddressTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đặt món ngay để thưởng thức và theo dõi đơn hàng tại đây.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AddressTheme.textMuted, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrderErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OrderErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AddressTheme.border),
            boxShadow: AddressTheme.softShadow,
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AddressTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AddressTheme.primary,
                  side: const BorderSide(color: AddressTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrderSkeletonList extends StatelessWidget {
  const OrderSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _OrderSkeletonCard(),
    );
  }
}

class _OrderSkeletonCard extends StatelessWidget {
  const _OrderSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F1), Color(0xFFFFEFDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 26, height: 26, decoration: _placeholder(true)),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 14, decoration: _placeholder())),
              const SizedBox(width: 10),
              Container(width: 70, height: 20, decoration: _placeholder()),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 12, width: 180, decoration: _placeholder()),
          const SizedBox(height: 6),
          Container(height: 12, width: 120, decoration: _placeholder()),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(height: 12, width: 100, decoration: _placeholder()),
              const Spacer(),
              Container(height: 12, width: 80, decoration: _placeholder()),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _placeholder([bool circle = false]) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: circle ? BorderRadius.circular(26) : BorderRadius.circular(10),
    );
  }
}
