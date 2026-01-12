import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

import '../seller_products_view_model.dart';
import 'product_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductViewData data;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.data,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.images.isNotEmpty ? data.images.first.url : null;
    final adminStatus = data.adminStatus?.trim().toUpperCase();
    final isBanned = adminStatus == 'BANNED';
    return Opacity(
      opacity: isBanned ? 0.5 : 1,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sellerCardRadius),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(sellerCardRadius),
        onTap: isBanned ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImageThumbnail(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF222222)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrency(data.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: sellerAccent,
                        fontSize: 16,
                      ),
                    ),
                    if (data.storeCategoryName != null || data.categoryName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        data.storeCategoryName ?? data.categoryName ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: sellerTextMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                    if (data.description?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          data.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SmallActionButton(
                          label: 'Sửa',
                          icon: Icons.edit_outlined,
                          onTap: isBanned ? null : onEdit,
                          background: sellerAccent.withOpacity(0.12),
                          color: sellerAccent,
                        ),
                        const SizedBox(width: 10),
                        _SmallActionButton(
                          label: 'Xóa',
                          icon: Icons.delete_outline,
                          onTap: isBanned ? null : onDelete,
                          background: const Color(0xFFFCE8E6),
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color color;

  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImageThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _ProductImageThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade200,
      ),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
