import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/voucher.dart';
import '../../../../../utils/currency_formatter.dart';

class OrderVoucherCard extends StatelessWidget {
  final String? adminVoucherTitle;
  final String? sellerVoucherTitle;
  final int? adminVoucherId;
  final int? sellerVoucherId;
  final double? adminVoucherDiscount;
  final double? sellerVoucherDiscount;
  final double totalDiscount;
  final Map<int, Map<String, dynamic>> adminVoucherDetail;
  final Map<int, Map<String, dynamic>> sellerVoucherDetail;

  const OrderVoucherCard({
    super.key,
    this.adminVoucherTitle,
    this.sellerVoucherTitle,
    this.adminVoucherId,
    this.sellerVoucherId,
    this.adminVoucherDiscount,
    this.sellerVoucherDiscount,
    required this.totalDiscount,
    this.adminVoucherDetail = const {},
    this.sellerVoucherDetail = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voucher áp dụng',
            style: TextStyle(fontWeight: FontWeight.w800, color: AddressTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          if (adminVoucherTitle != null || adminVoucherId != null)
            _line(
              'Sàn',
              adminVoucherTitle ?? 'mã: $adminVoucherId',
              adminVoucherDiscount,
              adminVoucherId,
              adminVoucherDetail,
            ),
          if (sellerVoucherTitle != null || sellerVoucherId != null)
            _line(
              'Shop',
              sellerVoucherTitle ?? 'mã: $sellerVoucherId',
              sellerVoucherDiscount,
              sellerVoucherId,
              sellerVoucherDetail,
            ),
          if (totalDiscount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Tổng giảm: -${formatCurrency(totalDiscount)}',
                style: const TextStyle(
                  color: AddressTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (adminVoucherTitle == null && sellerVoucherTitle == null && adminVoucherId == null && sellerVoucherId == null && totalDiscount <= 0)
            const Text(
              'Không áp dụng voucher',
              style: TextStyle(color: AddressTheme.textMuted),
            ),
        ],
      ),
    );
  }

  Widget _line(
    String label,
    String title,
    double? discount,
    int? voucherId,
    Map<int, Map<String, dynamic>> detailMap,
  ) {
    final detail = voucherId != null ? detailMap[voucherId] : null;
    final code = detail?['code'] as String?;
    final discountType = detail?['discountType'] as VoucherDiscountType?;

    final displayTitle = (code != null && code.isNotEmpty) ? code : title;

    String? discountTypeLabel;
    if (discountType == VoucherDiscountType.percentage) {
      discountTypeLabel = 'Giảm %';
    } else if (discountType == VoucherDiscountType.fixedAmount) {
      discountTypeLabel = 'Giảm tiền';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ===== CỘT TRÁI (50%) =====
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AddressTheme.badge,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AddressTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$displayTitle${discount != null ? ' (-${formatCurrency(discount)})' : ''}',
                    style: const TextStyle(
                      color: AddressTheme.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ===== CỘT GIỮA: DẤU | NẰM CHÍNH GIỮA =====
          SizedBox(
            width: 16, // thu hẹp để | sát hơn
            child: Center(
              child: Text(
                '|',
                style: TextStyle(
                  color: AddressTheme.textMuted.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // ===== CỘT PHẢI (50%) =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6), // khoảng cách ngắn với |
              child: Text(
                discountTypeLabel != null && discountTypeLabel.isNotEmpty
                    ? 'loại: $discountTypeLabel'
                    : '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AddressTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left, // QUAN TRỌNG: không align right nữa
              ),
            ),
          ),
        ],
      ),
    );
  }

}
