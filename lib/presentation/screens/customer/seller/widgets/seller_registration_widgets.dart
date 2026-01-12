import 'package:datn_foodecommerce_flutter_app/domain/entities/store.dart';
import 'package:flutter/material.dart';

import '../../addresses/widgets/address_theme.dart';

class SellerHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SellerHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7EE), Color(0xFFFFE9D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AddressTheme.primary.withOpacity(0.12),
            ),
            child: Icon(icon, color: AddressTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AddressTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AddressTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SellerSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SellerSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 32,
                decoration: BoxDecoration(
                  color: AddressTheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AddressTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AddressTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class SellerStatusCard extends StatelessWidget {
  final Store store;
  final String statusLabel;
  final String statusDescription;
  final bool isPending;
  final VoidCallback onRefresh;

  const SellerStatusCard({
    super.key,
    required this.store,
    required this.statusLabel,
    required this.statusDescription,
    required this.isPending,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isPending ? Colors.orange.shade100 : Colors.green.shade100;
    final badgeTextColor = isPending ? Colors.orange.shade800 : Colors.green.shade800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AddressTheme.primary.withOpacity(0.12),
                backgroundImage: store.imageUrl.isNotEmpty ? NetworkImage(store.imageUrl) : null,
                child: store.imageUrl.isEmpty
                    ? const Icon(Icons.store_mall_directory_outlined, color: AddressTheme.primary, size: 26)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AddressTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: AddressTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statusDescription,
            style: const TextStyle(
              fontSize: 14,
              color: AddressTheme.textMuted,
              height: 1.4,
            ),
          ),
          if (store.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Mo ta',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AddressTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              store.description,
              style: const TextStyle(color: AddressTheme.textPrimary, height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          SellerInfoRow(icon: Icons.location_on_outlined, label: store.address),
          SellerInfoRow(icon: Icons.phone_outlined, label: store.phone),
          SellerInfoRow(icon: Icons.email_outlined, label: store.email),
          if (store.openTime != null || store.closeTime != null)
            SellerInfoRow(
              icon: Icons.access_time,
              label:
                  '${store.openTime?.toLocalTimeString() ?? '--:--'} - ${store.closeTime?.toLocalTimeString() ?? '--:--'}',
            ),
        ],
      ),
    );
  }
}

class SellerInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const SellerInfoRow({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AddressTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AddressTheme.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SellerTipBox extends StatelessWidget {
  final String title;
  final String message;

  const SellerTipBox({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AddressTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AddressTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AddressTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: AddressTheme.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
