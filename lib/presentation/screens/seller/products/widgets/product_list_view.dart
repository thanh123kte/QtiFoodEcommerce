import 'package:flutter/material.dart';

import '../seller_products_view_model.dart';
import 'product_card.dart';
import 'product_theme.dart';

class ProductListView extends StatelessWidget {
  final List<ProductViewData> products;
  final Future<void> Function() onRefresh;
  final bool isProcessing;
  final void Function(ProductViewData) onTap;
  final void Function(ProductViewData) onEdit;
  final void Function(ProductViewData) onDelete;

  const ProductListView({
    super.key,
    required this.products,
    required this.onRefresh,
    required this.isProcessing,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return RefreshIndicator(
        color: sellerAccent,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 140),
            Icon(Icons.inbox_outlined, size: 64, color: Colors.orange.shade200),
            const SizedBox(height: 12),
            const Center(child: Text('Chua co san pham nao')),
            const SizedBox(height: 6),
            const Center(child: Text('Nhan "Them san pham" de bat dau')),
            const SizedBox(height: 180),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: sellerAccent,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemBuilder: (_, index) {
          final product = products[index];
          return ProductCard(
            data: product,
            onTap: () => onTap(product),
            onEdit: isProcessing ? null : () => onEdit(product),
            onDelete: isProcessing ? null : () => onDelete(product),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: products.length,
      ),
    );
  }
}
