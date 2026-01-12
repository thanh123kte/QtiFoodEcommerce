import 'package:flutter/material.dart';

import '../customer_dashboard_view_model.dart';

class DashboardNearbyStoreSection extends StatelessWidget {
  final List<DashboardNearbyStoreTile> stores;
  final bool isLoading;
  final String? error;
  final bool showViewMore;
  final VoidCallback onRetry;
  final ValueChanged<DashboardNearbyStoreTile> onStoreTap;

  const DashboardNearbyStoreSection({
    super.key,
    required this.stores,
    required this.isLoading,
    required this.error,
    required this.showViewMore,
    required this.onRetry,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF7A45);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Cửa hàng gần tôi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (isLoading && stores.isNotEmpty)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (isLoading && stores.isNotEmpty) const SizedBox(width: 10),
              if (showViewMore)
                Text(
                  'Xem thêm',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: accent, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (stores.isEmpty)
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              _NearbyStoreError(message: error!, onRetry: onRetry)
            else
              Text(
                'Chưa tìm thấy cửa hàng gần bạn.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final store = stores[index];
                return _NearbyStoreTile(
                  store: store,
                  onTap: () => onStoreTap(store),
                );
              },
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _NearbyStoreTile extends StatelessWidget {
  final DashboardNearbyStoreTile store;
  final VoidCallback onTap;

  const _NearbyStoreTile({
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = '${store.distanceKm.toStringAsFixed(1)} km';
    const tileBackground = Color(0xFFFFFBF7);
    final imageUrl = store.imageUrl;
    return Material(
      color: tileBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tileBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.storefront, color: Color(0xFFFF7A45)),
                        )
                      : const Icon(Icons.storefront, color: Color(0xFFFF7A45)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Icon(Icons.near_me_outlined, size: 18, color: Color(0xFFFF7A45)),
                  const SizedBox(height: 4),
                  Text(
                    distanceText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyStoreError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NearbyStoreError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined, color: Color(0xFFFF7A45)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
