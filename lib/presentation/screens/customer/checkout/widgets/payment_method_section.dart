import 'package:flutter/material.dart';

import '../../../seller/products/widgets/product_theme.dart';
import '../../../../../utils/currency_formatter.dart';

class PaymentMethodSection extends StatelessWidget {
  final String paymentMethod;
  final double walletBalance;
  final bool walletLoading;
  final bool canUseWallet;
  final ValueChanged<String?> onChanged;

  const PaymentMethodSection({
    super.key,
    required this.paymentMethod,
    required this.walletBalance,
    required this.walletLoading,
    required this.canUseWallet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.w600)),
            RadioListTile<String>(
              value: 'COD',
              groupValue: paymentMethod,
              onChanged: onChanged,
              title: const Text('COD'),
            ),
            RadioListTile<String>(
              value: 'QTIWALLET',
              groupValue: paymentMethod,
              onChanged: walletLoading || !canUseWallet ? null : onChanged,
              title: Row(
                children: [
                  const Text('QTI Wallet'),
                  const SizedBox(width: 8),
                  if (walletLoading)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text(
                      formatCurrency(walletBalance),
                      style: const TextStyle(color: sellerAccent),
                    ),
                ],
              ),
              subtitle: !canUseWallet
                  ? const Text('Số dư không đủ hoặc đang tải', style: TextStyle(color: Colors.red))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
