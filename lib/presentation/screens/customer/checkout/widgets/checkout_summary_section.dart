import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';

class CheckoutSummarySection extends StatelessWidget {
  final double subtotal;
  final double storeDiscount;
  final double discountedSubtotal;
  final double platformDiscount;
  final double shippingFee;
  final double total;
  final String? platformVoucher;

  const CheckoutSummarySection({
    super.key,
    required this.subtotal,
    required this.storeDiscount,
    required this.discountedSubtotal,
    required this.platformDiscount,
    required this.shippingFee,
    required this.total,
    required this.platformVoucher,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Tạm tính', formatCurrency(subtotal)),
            _row(
              'Giảm voucher cửa hàng',
              storeDiscount > 0 ? '-${formatCurrency(storeDiscount)}' : formatCurrency(0),
              highlight: storeDiscount > 0,
            ),
            _row('Sau voucher cửa hàng', formatCurrency(discountedSubtotal)),
            _row('Phí ship', formatCurrency(shippingFee)),
            _row(
              'Voucher sàn',
              platformDiscount > 0 ? '-${formatCurrency(platformDiscount)}' : (platformVoucher ?? 'Chưa áp dụng'),
              highlight: platformDiscount > 0,
            ),
            const Divider(height: 24),
            _row('Tổng thanh toán', formatCurrency(total), bold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
