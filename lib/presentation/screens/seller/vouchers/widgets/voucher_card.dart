import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/vouchers/seller_vouchers_view_model.dart';
import 'package:flutter/material.dart';

import '../../products/widgets/product_theme.dart';
import '../../../../../utils/currency_formatter.dart';
import 'voucher_utils.dart';

class VoucherCard extends StatelessWidget {
  final SellerVoucherViewData voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onEdit,
    required this.onDelete,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedStatus = resolveVoucherStatus(voucher);
    final statusColor = voucherStatusColor(context, resolvedStatus);
    final statusLabel = voucherStatusLabel(resolvedStatus);
    final usageLimit = voucher.usageLimit ?? 0;
    final usageCount = voucher.usageCount ?? 0;
    final usedRatio = usageLimit > 0 ? (usageCount / usageLimit).clamp(0.0, 1.0) : 0.0;
    final remainingRatio = voucherRemainingRatio(voucher);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sellerAccentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer, color: sellerAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            voucher.code,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sellerAccentSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SHOP',
                              style: TextStyle(
                                color: sellerAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        voucher.title,
                        style: const TextStyle(color: sellerTextMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (voucher.description != null && voucher.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                voucher.description!,
                style: const TextStyle(fontSize: 12, color: sellerTextMuted),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sellerAccentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.discount, color: sellerAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      voucherDiscountDescription(voucher),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: sellerAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  voucher.minOrderValue == null
                      ? 'Không yêu cầu đơn tối thiểu'
                      : 'Đơn tối thiểu: ${formatCurrency(voucher.minOrderValue!)}',
                  style: const TextStyle(fontSize: 12, color: sellerTextMuted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  usageLimit > 0 ? 'Đã sử dụng: $usageCount/$usageLimit' : 'Không giới hạn',
                  style: const TextStyle(fontSize: 12, color: sellerTextMuted),
                ),
                const SizedBox(width: 8),
                if (usageLimit > 0)
                  Text(
                    '(${(usedRatio * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: usedRatio >= 0.8 ? Colors.red : sellerTextMuted,
                      fontWeight: usedRatio >= 0.8 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Thời hạn: ${voucherDateRangeText(voucher.startDate, voucher.endDate)}',
                  style: const TextStyle(fontSize: 12, color: sellerTextMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến độ sử dụng',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: sellerTextMuted),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: remainingRatio,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingRatio <= 0.2 ? Colors.red : sellerAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  voucherUsageText(voucher),
                  style: const TextStyle(fontSize: 12, color: sellerTextMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Chi tiết'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Chỉnh sửa'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Xóa',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
