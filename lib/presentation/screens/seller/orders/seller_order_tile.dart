import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../products/widgets/product_theme.dart';
import '../../../../utils/currency_formatter.dart';
import 'seller_orders_view_model.dart';

class SellerOrderTile extends StatelessWidget {
  final SellerOrderListItem order;
  final VoidCallback onTap;

  const SellerOrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rawStatus = order.status ?? 'PENDING';
    final statusText = _statusLabel(rawStatus);
    final dateText = order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : '';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sellerAccentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: sellerAccent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đơn: ${order.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        if ((order.customerName ?? '').isNotEmpty)
                          Text('Khách: ${order.customerName}', style: const TextStyle(color: sellerTextMuted)),
                      ],
                    ),
                  ),
                  _StatusChip(label: statusText, rawStatus: rawStatus),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng: ${formatCurrency(order.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    order.paymentMethod,
                    style: const TextStyle(color: sellerTextMuted),
                  ),
                ],
              ),
              if (dateText.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(dateText, style: const TextStyle(color: sellerTextMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String rawStatus;

  const _StatusChip({required this.label, required this.rawStatus});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(rawStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toUpperCase();
    if (normalized.startsWith('PENDING')) return Colors.orange;
    if (normalized.startsWith('CONFIRMED')) return Colors.blue;
    if (normalized.startsWith('PREPARING')) return Colors.deepPurple;
    if (normalized.startsWith('PREPARED')) return Colors.green;
    if (normalized.startsWith('DELIVERED'))return Colors.teal;
    if (normalized.startsWith('CANCEL')) return Colors.redAccent;
    return Colors.grey;
  }

} 

String _statusLabel(String raw) {
  final normalized = raw.toUpperCase();
  if (normalized.startsWith('PENDING')) {
    return 'Mới';
  }
  if (normalized.startsWith('CONFIRMED')) {
    return 'Đã xác nhận';
  }
  if (normalized.startsWith('PREPARING')) {
    return 'Đang làm';
  }
  if (normalized.startsWith('PREPARED')) {
    return 'Sẵn sàng giao';
  }
  if (normalized.startsWith('DELIVERING')) {
    return 'Đang giao';
  }
  if (normalized.startsWith('DELIVERED')) {
    return 'Hoàn thành';
  }
  if (normalized.startsWith('CANCEL')) {
    return 'Đã hủy';
  }
  return raw;
}
