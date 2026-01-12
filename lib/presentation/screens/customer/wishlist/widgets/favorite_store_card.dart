import 'package:datn_foodecommerce_flutter_app/domain/entities/store.dart';
import 'package:flutter/material.dart';

import '../../addresses/widgets/address_theme.dart';

class FavoriteStoreCard extends StatelessWidget {
  final Store store;
  final bool isRemoving;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteStoreCard({
    super.key,
    required this.store,
    required this.isRemoving,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isRemoving ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AddressTheme.border),
          boxShadow: AddressTheme.softShadow,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _StoreImage(imageUrl: store.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name.isNotEmpty ? store.name : 'Quan an',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AddressTheme.textPrimary,
                          ),
                        ),
                      ),
                      _FavoriteBadge(isRemoving: isRemoving, onRemove: onRemove),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (store.address.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AddressTheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AddressTheme.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (store.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      store.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AddressTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreImage extends StatelessWidget {
  final String imageUrl;

  const _StoreImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF2E6), Color(0xFFFFE5CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.store_mall_directory_outlined, color: AddressTheme.primary),
    );

    if (imageUrl.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        height: 72,
        width: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: 72,
            width: 72,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  final bool isRemoving;
  final VoidCallback onRemove;

  const _FavoriteBadge({required this.isRemoving, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isRemoving ? null : onRemove,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          Icons.favorite,
          color: isRemoving ? Colors.grey : AddressTheme.primary,
          size: 22,
        ),
      ),
    );
  }
}
