import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/addresses_ui_state.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final AddressViewData data;
  final bool showDefaultBadge;
  final VoidCallback onEdit;

  const AddressCard({
    super.key,
    required this.data,
    required this.showDefaultBadge,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AddressTheme.surface,
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
              _AddressIcon(showDefault: showDefaultBadge),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.address,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AddressTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (showDefaultBadge)
                          const AddressPill(
                            label: 'Mặc định',
                            icon: Icons.star_rounded,
                            color: Color(0xFFFFF0E0),
                          )
                        else
                          const AddressPill(
                            label: 'Đã lưu',
                            icon: Icons.check_circle,
                          ),
                        AddressPill(
                          label: data.receiver,
                          icon: Icons.person_outline,
                          color: AddressTheme.badge,
                        ),
                        AddressPill(
                          label: data.phone,
                          icon: Icons.phone_outlined,
                          color: AddressTheme.badge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AddressTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AddressTheme.border),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  'Chỉnh sửa',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEFE2D8)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Người nhận',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.2,
                        color: AddressTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.receiver,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AddressTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số điện thoại',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.2,
                        color: AddressTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AddressTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressIcon extends StatelessWidget {
  final bool showDefault;

  const _AddressIcon({required this.showDefault});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0E3), Color(0xFFFFE3CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Icon(
        showDefault ? Icons.bookmark_rounded : Icons.location_on_outlined,
        size: 22,
        color: AddressTheme.primary,
      ),
    );
  }
}
