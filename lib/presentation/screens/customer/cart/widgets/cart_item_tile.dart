import 'package:flutter/material.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import '../cart_view_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItemViewData item;
  final bool selected;
  final VoidCallback onToggleSelect;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool isUpdating;
  final bool isRemoving;

  const CartItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggleSelect,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
    required this.isUpdating,
    required this.isRemoving,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primary = Color(0xFFFF7A45);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isRemoving ? 0.55 : 1,
      child: InkWell(
        onTap: isRemoving ? null : onToggleSelect,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? primary : Colors.black.withOpacity(0.05),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh + shadow nhẹ
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: item.imageUrl == null
                          ? Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade500)
                          : Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey.shade500,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Nội dung
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + remove (đúng UX: chỉ nổi khi có thể bấm)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            _RemoveButton(
                              primary: primary,
                              enabled: selected && !isRemoving,
                              loading: isRemoving,
                              onTap: onRemove,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PriceChip(
                              label: 'Đơn giá',
                              value: formatCurrency(item.unitPrice),
                              primary: primary,
                              emphasize: true,
                            ),
                            _PriceChip(
                              label: 'Tạm tính',
                              value: formatCurrency(item.totalPrice),
                              primary: primary,
                              emphasize: false,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: (item.quantity > 1 && !isUpdating && !isRemoving) ? onDecrease : null,
                            ),
                            const SizedBox(width: 10),

                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: primary.withOpacity(0.08),
                                border: Border.all(color: primary.withOpacity(0.18)),
                              ),
                              child: isUpdating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      '${item.quantity}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 10),
                            _QuantityButton(
                              icon: Icons.add,
                              onTap: (!isUpdating && !isRemoving) ? onIncrease : null,
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _PriceChip extends StatelessWidget {
  final String label;
  final String value;
  final Color primary;
  final bool emphasize;

  const _PriceChip({
    required this.label,
    required this.value,
    required this.primary,
    required this.emphasize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: emphasize ? primary.withOpacity(0.10) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasize ? primary.withOpacity(0.20) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: emphasize ? primary : Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final Color primary;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _RemoveButton({
    required this.primary,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
        minimumSize: WidgetStateProperty.all(const Size(0, 0)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.grey.shade500;
          return Colors.redAccent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return BorderSide.none; // ✅ không viền khi disabled
          return const BorderSide(color: Colors.redAccent); // ✅ có viền khi enabled
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.transparent;
          return Colors.redAccent.withOpacity(0.06);
        }),
      ),
      child: loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.delete_outline, size: 18),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);

    return Ink(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onTap == null ? Colors.grey.shade200 : primary.withOpacity(0.12),
        border: Border.all(
          color: onTap == null ? Colors.transparent : primary.withOpacity(0.18),
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: onTap == null ? Colors.grey : primary),
        onPressed: onTap,
        splashRadius: 22,
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
