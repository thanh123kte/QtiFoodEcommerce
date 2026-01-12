import 'package:datn_foodecommerce_flutter_app/domain/entities/wallet_transaction.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletTransactionDetailScreen extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(transaction.transactionType);
    final icon = _statusIcon(transaction.transactionType, transaction.amount);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _AmountHeader(color: color, icon: icon, transaction: transaction),
            const SizedBox(height: 16),
            _InfoTile(label: 'Loại giao dịch', value: _localizedType(transaction.transactionType)),
            if (transaction.status != null) _InfoTile(
              label: 'Trạng thái',
              value: _localizedStatus(transaction.status!),
              valueColor: _statusColorFromStatus(transaction.status!),
            ),
            _InfoTile(label: 'Mô tả', value: transaction.description.isEmpty ? 'Không có mô tả' : transaction.description),
            _InfoTile(label: 'Mã tham chiếu', value: transaction.referenceId.isEmpty ? '-' : transaction.referenceId),
            _InfoTile(label: 'Kiểu tham chiếu', value: transaction.referenceType.isEmpty ? '-' : transaction.referenceType),
            _InfoTile(label: 'Số tiền', value: _formatSignedAmount(transaction.amount, transaction.transactionType), valueColor: color),
            _InfoTile(label: 'Số dư trước', value: formatCurrency(transaction.balanceBefore)),
            _InfoTile(label: 'Số dư sau', value: formatCurrency(transaction.balanceAfter)),
            _InfoTile(label: 'Thời gian', value: _formatDate(transaction.createdAt)),
          ],
        ),
      ),
    );
  }
}

class _AmountHeader extends StatelessWidget {
  final Color color;
  final IconData icon;
  final WalletTransaction transaction;

  const _AmountHeader({required this.color, required this.icon, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_localizedType(transaction.transactionType), style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  _formatSignedAmount(transaction.amount, transaction.transactionType),
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title / Label
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          /// Value (cho phép xuống hàng)
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}

String _formatSignedAmount(double amount, String type) {
  final outflow = _isOutflow(type, amount);
  final prefix = outflow ? '-' : '+';
  return '$prefix${formatCurrency(amount.abs())}';
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

String _localizedType(String type) {
  final upper = type.toUpperCase();
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return 'Doanh thu';
  if (upper.contains('PAY')) return 'Thanh toán';
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return 'Nạp tiền';
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return 'Rút tiền';
  if (upper.contains('REFUND')) return 'Hoàn tiền';
  return 'Giao dịch';
}

Color _statusColor(String type) {
  final upper = type.toUpperCase();
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return const Color.fromARGB(255, 243, 159, 33);
  if (upper.contains('PAY')) return const Color(0xFFFF7A45);
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return Colors.green;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return Colors.red;
  if (upper.contains('REFUND')) return Colors.teal;
  return Colors.blueGrey;
}

IconData _statusIcon(String type, double amount) {
  final upper = type.toUpperCase();
  if (upper.contains('INCOME') || upper.contains('REVENUE') || upper.contains('EARNING') || upper.contains('EARN')) return Icons.trending_up_rounded;
  if (upper.contains('PAY')) return Icons.shopping_bag_outlined;
  if (upper.contains('TOPUP') || upper.contains('DEPOSIT') || upper.contains('DEPOSITE')) return Icons.arrow_downward_rounded;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return Icons.call_made_rounded;
  if (upper.contains('REFUND')) return Icons.reply;
  return amount >= 0 ? Icons.call_received : Icons.call_made;
}

bool _isOutflow(String type, double amount) {
  final upper = type.toUpperCase();
  if (upper.contains('PAY')) return true;
  if (upper.contains('WITHDRAW') || upper.contains('WITH_DRAW')) return true;
  if (amount < 0) return true;
  return false;
}

String _localizedStatus(String status) {
  final upper = status.toUpperCase();
  switch (upper) {
    case 'PENDING':
      return 'Đang chờ duyệt';
    case 'APPROVED':
      return 'Đã duyệt';
    case 'SUCCESSFUL':
      return 'Thành công';
    case 'REJECTED':
      return 'Đã từ chối';
    default:
      return status;
  }
}

Color _statusColorFromStatus(String status) {
  final upper = status.toUpperCase();
  switch (upper) {
    case 'PENDING':
      return Colors.orange;
    case 'APPROVED':
    case 'SUCCESSFUL':
      return Colors.green;
    case 'REJECTED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
