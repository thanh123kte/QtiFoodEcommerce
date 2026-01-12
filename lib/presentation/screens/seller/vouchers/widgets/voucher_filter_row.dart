import 'package:flutter/material.dart';

import '../../products/widgets/product_theme.dart';

class VoucherFilterRow extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  static const List<String> filters = ['Tất cả', 'Hoạt động', 'Hết hạn', 'Tạm ngưng'];

  const VoucherFilterRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _FilterPill(
                    label: filter,
                    selected: selectedFilter == filter,
                    onTap: () => onFilterChanged(filter),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFFFF3E8) : Colors.white;
    final fg = selected ? sellerAccent : const Color(0xFF374151);
    final borderColor = selected ? const Color(0xFFFFE0C2) : sellerBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: sellerAccent.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 16, color: sellerAccent),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
