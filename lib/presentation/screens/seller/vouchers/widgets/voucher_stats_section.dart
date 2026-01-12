
import 'package:datn_foodecommerce_flutter_app/domain/entities/voucher.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/vouchers/seller_vouchers_view_model.dart';
import 'package:flutter/material.dart';

import '../../products/widgets/product_theme.dart';
import 'voucher_utils.dart';

class VoucherStatsSection extends StatelessWidget {
  final List<SellerVoucherViewData> vouchers;

  const VoucherStatsSection({super.key, required this.vouchers});

  @override
  Widget build(BuildContext context) {
    final total = vouchers.length;
    final active = _countStatus(vouchers, VoucherStatus.active);
    final expired = _countStatus(vouchers, VoucherStatus.expired);
    final inactive = _countStatus(vouchers, VoucherStatus.inactive);
    final totalUsage = _totalUsage(vouchers);
    final usageRateText = _usageRateText(vouchers);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Tổng số', value: '$total', color: sellerAccent),
              _StatItem(label: 'Hoạt động', value: '$active', color: Colors.green.shade600),
              _StatItem(label: 'Hết hạn', value: '$expired', color: Colors.redAccent),
              _StatItem(label: 'Tạm ngưng', value: '$inactive', color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sellerAccentSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sellerBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$totalUsage',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sellerAccent,
                      ),
                    ),
                    const Text('Lượt sử dụng', style: TextStyle(fontSize: 11, color: sellerTextMuted)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      usageRateText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sellerAccent,
                      ),
                    ),
                    const Text('Tỷ lệ sử dụng', style: TextStyle(fontSize: 11, color: sellerTextMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countStatus(List<SellerVoucherViewData> list, VoucherStatus status) {
    return list.where((voucher) => resolveVoucherStatus(voucher) == status).length;
  }

  int _totalUsage(List<SellerVoucherViewData> list) {
    return list.fold<int>(0, (sum, voucher) => sum + (voucher.usageCount ?? 0));
  }

  String _usageRateText(List<SellerVoucherViewData> list) {
    int totalUsage = 0;
    int totalLimit = 0;
    for (final voucher in list) {
      final limit = voucher.usageLimit ?? 0;
      final used = voucher.usageCount ?? 0;
      totalUsage += used;
      if (limit > 0) {
        totalLimit += limit;
      }
    }
    if (totalLimit == 0) return '--';
    final ratio = (totalUsage / totalLimit).clamp(0.0, 1.0);
    return '${(ratio * 100).toStringAsFixed(1)}%';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
