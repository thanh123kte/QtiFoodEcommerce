import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';
import '../../../seller/products/widgets/product_theme.dart';

class CheckoutHeader extends StatelessWidget {
  final int itemCount;
  final int storeCount;
  final double subtotal;

  const CheckoutHeader({
    super.key,
    required this.itemCount,
    required this.storeCount,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: sellerAccentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: sellerAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thanh toán', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '$itemCount sản phẩm • $storeCount cửa hàng',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Tạm tính', style: TextStyle(color: sellerTextMuted, fontSize: 12)),
              Text(
                formatCurrency(subtotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
