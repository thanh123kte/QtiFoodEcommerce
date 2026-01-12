import 'package:flutter/material.dart';

import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';

class CartSummaryBar extends StatelessWidget {
  final double total;
  final int selectedCount;
  final bool hasSelection;
  final VoidCallback onDelete;
  final VoidCallback onCheckout;
  final bool isProcessing;
  final bool isAllSelected;
  final ValueChanged<bool> onSelectAll;

  const CartSummaryBar({
    super.key,
    required this.total,
    required this.selectedCount,
    required this.hasSelection,
    required this.onDelete,
    required this.onCheckout,
    required this.isProcessing,
    required this.isAllSelected,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primary = Color(0xFFFF7A45);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.orange.shade100)),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng'),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: (!hasSelection || isProcessing) ? null : onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Xóa'),
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey;
                      }
                      return Colors.redAccent; 
                    }),
                    side: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return BorderSide.none; 
                      }
                      return const BorderSide(color: Colors.redAccent); // ✅ có viền khi active
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: hasSelection ? onCheckout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Thanh toán'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
