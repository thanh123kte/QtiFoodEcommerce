import 'package:flutter/material.dart';

class CartSelectAllTile extends StatelessWidget {
  final int totalCount;
  final int selectedCount;
  final ValueChanged<bool> onSelectAll;

  const CartSelectAllTile({
    super.key,
    required this.totalCount,
    required this.selectedCount,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);
    final bool allSelected = totalCount > 0 && selectedCount == totalCount;
    final bool partiallySelected = !allSelected && selectedCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: allSelected
                ? true
                : partiallySelected
                    ? null
                    : false,
            tristate: true,
            onChanged: (_) => onSelectAll(!allSelected),
          ),
          Expanded(
            child: Text(
              'Chọn tất cả',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (selectedCount > 0)
            Text(
              '$selectedCount đã chọn',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
