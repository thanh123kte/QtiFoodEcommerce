import 'package:flutter/material.dart';

import '../../../../../domain/entities/address.dart';
import '../../../seller/products/widgets/product_theme.dart';

class CheckoutShippingSection extends StatelessWidget {
  final Address? address;
  final bool hasAddresses;
  final bool isLoading;
  final String? error;
  final VoidCallback onSelect;
  final VoidCallback onRetry;

  const CheckoutShippingSection({
    super.key,
    required this.address,
    required this.hasAddresses,
    required this.isLoading,
    required this.error,
    required this.onSelect,
    required this.onRetry,
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
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: sellerAccent),
                const SizedBox(width: 8),
                Text('Địa chỉ giao hàng', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: isLoading ? null : onSelect,
                  child: Text(hasAddresses ? 'Chọn địa chỉ' : 'Thêm địa chỉ'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else if (error != null)
              Row(
                children: [
                  Expanded(child: Text(error!, style: const TextStyle(color: Colors.red))),
                  TextButton(onPressed: onRetry, child: const Text('Thử lại')),
                ],
              )
            else if (address != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${address!.receiver} | ${address!.phone}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(address!.address),
                ],
              )
            else
              const Text('Chưa có địa chỉ, vui lòng thêm.'),
          ],
        ),
      ),
    );
  }
}
