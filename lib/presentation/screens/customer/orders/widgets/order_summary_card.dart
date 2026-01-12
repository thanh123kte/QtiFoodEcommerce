import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';

class OrderSummaryCard extends StatelessWidget {
  final double itemsTotal;
  final double discount;
  final double shipping;
  final double total;

  const OrderSummaryCard({
    super.key,
    required this.itemsTotal,
    required this.discount,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Column(
        children: [
          _row('Tạm tính', formatCurrency(itemsTotal)),
          _row(
            'Giảm giá',
            '-${formatCurrency(discount)}',
            valueStyle: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w700),
          ),
          _row('Phí ship', formatCurrency(shipping)),
          const Divider(),
          _row(
            'Tổng thanh toán',
            formatCurrency(total),
            valueStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AddressTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AddressTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  color: AddressTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
