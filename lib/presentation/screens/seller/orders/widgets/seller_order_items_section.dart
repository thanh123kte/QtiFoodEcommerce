import 'package:datn_foodecommerce_flutter_app/utils/resolve_image_url.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';
import '../seller_order_detail_view_model.dart';
import '../../products/widgets/product_theme.dart';

class SellerOrderItemsSection extends StatelessWidget {
  final SellerOrderDetailViewModel vm;

  const SellerOrderItemsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.itemsError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sellerAccentSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sellerBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.itemsError!, style: const TextStyle(color: sellerAccent)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sellerAccent, foregroundColor: Colors.white),
              onPressed: () => vm.order != null ? vm.loadItems() : null,
              child: const Text('Thu lai'),
            ),
          ],
        ),
      );
    }
    if (vm.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sellerBorder),
        ),
        child: const Text('Khong co san pham'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sellerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('San pham', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...vm.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrl == null || item.imageUrl!.isEmpty
                              ? Container(
                                  width: 44,
                                  height: 44,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, size: 18),
                                )
                              : Image.network(
                                  resolveImageUrl(item.imageUrl)!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, size: 18),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name ?? item.productId, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('x${item.quantity}', style: const TextStyle(color: sellerTextMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatCurrency(item.price * item.quantity)),
                      if (item.originalPrice != null && item.originalPrice! > item.price)
                        Text(
                          formatCurrency(item.originalPrice! * item.quantity),
                          style: const TextStyle(
                            color: sellerTextMuted,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
