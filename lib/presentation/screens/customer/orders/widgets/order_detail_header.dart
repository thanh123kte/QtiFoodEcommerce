import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailHeader extends StatelessWidget {
  final int orderId;
  final String storeName;
  final String paymentMethod;
  final DateTime? createdAt;
  final DateTime? expectedDeliveryTime;
  final String? status;
  final String? note;

  const OrderDetailHeader({
    super.key,
    required this.storeName,
    required this.orderId,
    required this.paymentMethod,
    required this.createdAt,
    required this.expectedDeliveryTime,
    required this.status,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final createdText = createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) : 'Chua ro';
    final expectedText =
        expectedDeliveryTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(expectedDeliveryTime!) : 'Chua co';
    final rawStatus = status ?? 'PENDING';
    final statusText = _localizedStatus(rawStatus);
    final statusColor = _statusColor(rawStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AddressTheme.primary.withOpacity(0.1),
                ),
                child: Icon(Icons.receipt_long, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã đơn: $orderId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AddressTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cửa hàng: $storeName',
                      style: const TextStyle(
                        color: AddressTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.payments_outlined,
            label: 'Thanh toán: $paymentMethod',
          ),
          _InfoLine(
            icon: Icons.schedule,
            label: 'Tạo lúc: $createdText',
          ),
          _InfoLine(
            icon: Icons.local_shipping_outlined,
            label: 'Dự kiến giao: $expectedText',
          ),
          if ((note ?? '').isNotEmpty)
            _InfoLine(
              icon: Icons.notes_outlined,
              label: 'Ghi chú: $note',
            ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AddressTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AddressTheme.textPrimary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
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
  if (normalized.startsWith('CONFIRMED') || normalized.startsWith('ACCEPT')) return 'Đã xác nhận';
  if (normalized.startsWith('PREPARING') || normalized.startsWith('PREPARE')) return 'Đang chuẩn bị';
  if (normalized.startsWith('PREPARED') || normalized.startsWith('READY')) return 'Sẵn sàng giao';
  if (normalized.startsWith('SHIP') || normalized.startsWith('DELIVERING')) return 'Đang giao';
  if (normalized.startsWith('DELIVERED') || normalized.startsWith('COMPLETED')) return 'Đã giao';
  if (normalized.startsWith('REVIEWED')) return 'Đã đánh giá';
  if (normalized.startsWith('CANCEL')) return 'Đã hủy';
  return 'Đang xử lý';
}
