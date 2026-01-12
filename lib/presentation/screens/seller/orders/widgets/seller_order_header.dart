import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/order.dart';
import '../../products/widgets/product_theme.dart';

class SellerOrderHeader extends StatelessWidget {
  final Order order;

  const SellerOrderHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final createdText = order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : 'Chua ro';
    final expectedText =
        order.expectedDeliveryTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.expectedDeliveryTime!) : 'Chua ro';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
      ),
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
                    Text('Ma don: ${order.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    if ((order.customerName ?? '').isNotEmpty)
                      Text('Khach hang: ${order.customerName}', style: const TextStyle(color: sellerTextMuted)),
                  ],
                ),
              ),
              _StatusTag(status: order.status ?? 'PENDING'),
            ],
          ),
          const SizedBox(height: 10),
          _Row(label: 'Thanh toan', value: order.paymentMethod),
          _Row(label: 'Tao luc', value: createdText),
          _Row(label: 'Du kien giao', value: expectedText),
          if ((order.note ?? '').isNotEmpty) _Row(label: 'Ghi chu', value: order.note!),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: sellerTextMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toUpperCase();
    if (normalized.startsWith('PENDING')) return Colors.orange;
    if (normalized.startsWith('CONFIRMED')) return Colors.blue;
    if (normalized.startsWith('PREPARING')) return Colors.deepPurple;
    if (normalized.startsWith('PREPARED')) return Colors.green;
    if (normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED')) return Colors.teal;
    if (normalized.startsWith('CANCEL')) return Colors.redAccent;
    return Colors.grey;
  }
}
