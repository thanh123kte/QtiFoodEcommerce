import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

import '../customer_dashboard_view_model.dart';

class DashboardProductGrid extends StatelessWidget {
  final List<DashboardProductTile> products;
  final ValueChanged<DashboardProductTile> onProductTap;
  final void Function(DashboardProductTile tile, Rect? imageRect)? onQuickAdd;
  final Set<String> addingProductIds;

  const DashboardProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onQuickAdd,
    this.addingProductIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, index) => _DashboardProductCard(
          tile: products[index],
          isAdding: addingProductIds.contains(products[index].id),
          onTap: () => onProductTap(products[index]),
          onQuickAdd: onQuickAdd,
        ),
        childCount: products.length,
      ),
    );
  }
}

class _DashboardProductCard extends StatelessWidget {
  final DashboardProductTile tile;
  final VoidCallback onTap;
  final void Function(DashboardProductTile tile, Rect? imageRect)? onQuickAdd;
  final bool isAdding;
  final GlobalKey _imageKey = GlobalKey();

  _DashboardProductCard({
    required this.tile,
    required this.onTap,
    required this.isAdding,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);
    final displayImage = tile.imageUrl ?? (tile.imageUrls.isNotEmpty ? tile.imageUrls.first : null);
    final status = tile.status.trim().toUpperCase();
    final isUnavailable = status.contains('UNAVAILABLE');
    return Opacity(
      opacity: isUnavailable ? 0.5 : 1,
      child: GestureDetector(
        onTap: isUnavailable ? null : onTap,
        child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                key: _imageKey,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: displayImage == null
                    ? Container(
                        color: Colors.grey.shade100,
                        child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                      )
                    : Image.network(
                        displayImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${tile.rating} (${tile.reviewCount})', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(tile.discountPrice ?? tile.price),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: primary, fontWeight: FontWeight.w800),
                  ),
                  if (tile.discountPrice != null)
                    Text(
                      formatCurrency(tile.price),
                      style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUnavailable || isAdding || onQuickAdd == null
                          ? null
                          : () {
                              Rect? rect;
                              final context = _imageKey.currentContext;
                              if (context != null) {
                                final box = context.findRenderObject();
                                if (box is RenderBox) {
                                  rect = box.localToGlobal(Offset.zero) & box.size;
                                }
                              }
                              onQuickAdd!(tile, rect);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primary.withOpacity(0.6),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: isAdding
                            ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Thêm ngay', key: ValueKey('idle'), style: TextStyle(fontWeight: FontWeight.w700),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
