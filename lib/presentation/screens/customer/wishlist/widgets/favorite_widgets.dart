import 'package:flutter/material.dart';

import '../../addresses/widgets/address_theme.dart';

class FavoriteHeroCard extends StatelessWidget {
  final int count;

  const FavoriteHeroCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7EE), Color(0xFFFFEADA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AddressTheme.primary.withOpacity(0.12),
            ),
            child: const Icon(Icons.favorite_rounded, color: AddressTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quán ăn yêu thích',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AddressTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  count > 0
                      ? 'Bạn có $count quán ăn đang được lưu.'
                      : 'Giữ danh sách yêu thích để đặt lại nhanh hơn.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AddressTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AddressTheme.badge,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AddressTheme.border),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AddressTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteEmptyView extends StatelessWidget {
  final VoidCallback onExplore;

  const FavoriteEmptyView({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AddressTheme.border),
            boxShadow: AddressTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AddressTheme.primary.withOpacity(0.08),
                ),
                child: const Icon(Icons.favorite_border, size: 40, color: AddressTheme.primary),
              ),
              const SizedBox(height: 14),
              const Text(
                'Chưa có quán ăn yêu thích',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AddressTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lưu lại quán ăn ngon để trở lại nhanh và đặt hàng tiện lợi hơn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AddressTheme.textMuted, height: 1.45),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onExplore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddressTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.search),
                label: const Text(
                  'Tìm quán ngon',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FavoriteErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FavoriteErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AddressTheme.border),
            boxShadow: AddressTheme.softShadow,
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AddressTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AddressTheme.primary,
                  side: const BorderSide(color: AddressTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FavoriteSkeletonList extends StatelessWidget {
  const FavoriteSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _FavoriteSkeletonCard(),
    );
  }
}

class _FavoriteSkeletonCard extends StatelessWidget {
  const _FavoriteSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F1), Color(0xFFFFEFDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 140, decoration: _placeholder()),
                const SizedBox(height: 8),
                Container(height: 12, width: double.infinity, decoration: _placeholder()),
                const SizedBox(height: 6),
                Container(height: 12, width: 180, decoration: _placeholder()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(height: 12, width: 80, decoration: _placeholder()),
                    const SizedBox(width: 10),
                    Container(height: 12, width: 90, decoration: _placeholder()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _placeholder() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    );
  }
}
