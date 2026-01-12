import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/orders/order_detail_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/utils/resolve_image_url.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';

class OrderItemsSection extends StatelessWidget {
  final OrderDetailViewModel vm;

  const OrderItemsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const _ContainerWrapper(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(color: AddressTheme.primary),
          ),
        ),
      );
    }
    if (vm.error != null) {
      return _ContainerWrapper(
        child: Column(
          children: [
            Text(vm.error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => vm.order != null ? vm.loadItems(vm.order!.id) : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AddressTheme.primary,
                side: const BorderSide(color: AddressTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (vm.items.isEmpty) {
      return const _ContainerWrapper(
        child: Text('Không có món hàng'),
      );
    }

    return _ContainerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm',
            style: TextStyle(fontWeight: FontWeight.w800, color: AddressTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          ...vm.items.map(
            (item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    _ItemThumb(name: item.name ?? item.productId, imageUrl: resolveImageUrl(item.imageUrl)),
                    const SizedBox(width: 8),
                    Text('x${item.quantity}', style: const TextStyle(color: AddressTheme.textMuted)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(item.price * item.quantity),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AddressTheme.textPrimary,
                          ),
                        ),
                        if (item.originalPrice != null && item.originalPrice! > item.price)
                          Text(
                            formatCurrency(item.originalPrice! * item.quantity),
                            style: const TextStyle(
                              color: AddressTheme.textMuted,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}

class _ContainerWrapper extends StatelessWidget {
  final Widget child;

  const _ContainerWrapper({required this.child});

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
      child: child,
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ItemThumb({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl == null || imageUrl!.isEmpty
                ? Container(
                    width: 44,
                    height: 44,
                    color: AddressTheme.badge,
                    child: const Icon(Icons.image_not_supported, size: 18, color: AddressTheme.primary),
                  )
                : Image.network(
                    imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: AddressTheme.badge,
                      child: const Icon(Icons.broken_image, size: 18, color: AddressTheme.primary),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AddressTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
