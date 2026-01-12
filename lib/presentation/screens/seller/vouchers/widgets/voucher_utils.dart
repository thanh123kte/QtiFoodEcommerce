import 'package:datn_foodecommerce_flutter_app/domain/entities/voucher.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/vouchers/seller_vouchers_view_model.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/currency_formatter.dart';

VoucherStatus resolveVoucherStatus(SellerVoucherViewData voucher) {
  final now = DateTime.now();
  final end = voucher.endDate;
  final start = voucher.startDate;

  final isExpired = voucher.status == VoucherStatus.expired || (end != null && now.isAfter(end));
  if (isExpired) return VoucherStatus.expired;

  if (voucher.status == VoucherStatus.scheduled || voucher.status == VoucherStatus.draft) {
    return VoucherStatus.inactive;
  }

  if (!voucher.isActive || voucher.status == VoucherStatus.inactive) return VoucherStatus.inactive;
  if (start != null && now.isBefore(start)) return VoucherStatus.inactive;

  if (voucher.status != VoucherStatus.active) return VoucherStatus.inactive;

  return VoucherStatus.active;
}

Color voucherStatusColor(BuildContext context, VoucherStatus status) {
  switch (status) {
    case VoucherStatus.active:
      return Colors.green;
    case VoucherStatus.inactive:
      return Colors.grey;
    case VoucherStatus.scheduled:
      return Theme.of(context).colorScheme.primary;
    case VoucherStatus.expired:
      return Colors.redAccent;
    case VoucherStatus.draft:
    case VoucherStatus.unknown:
      return Colors.orange;
  }
}

String voucherStatusLabel(VoucherStatus status) {
  switch (status) {
    case VoucherStatus.active:
      return 'ACTIVE';
    case VoucherStatus.inactive:
      return 'SUSPENDED';
    case VoucherStatus.scheduled:
      return 'SCHEDULED';
    case VoucherStatus.expired:
      return 'EXPIRED';
    case VoucherStatus.draft:
      return 'DRAFT';
    case VoucherStatus.unknown:
      return 'UNKNOWN';
  }
}

String voucherDiscountDescription(SellerVoucherViewData voucher) {
  if (voucher.discountType == VoucherDiscountType.percentage) {
    final max = voucher.maxDiscount == null ? '' : ' (toi da ${formatCurrency(voucher.maxDiscount!)})';
    return 'Giảm ${voucher.discountValue.toStringAsFixed(0)}%$max';
  }
  return 'Giảm ${formatCurrency(voucher.discountValue)}';
}

String voucherDateRangeText(DateTime? start, DateTime? end) {
  if (start == null || end == null) return 'Chưa thiết lập khoảng thời gian';
  final startText =
      '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  final endText =
      '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')} ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  return '$startText - $endText';
}

double voucherRemainingRatio(SellerVoucherViewData voucher) {
  final usageLimit = voucher.usageLimit ?? 0;
  if (usageLimit <= 0) return 1;
  final used = voucher.usageCount ?? 0;
  final usedRatio = (used / usageLimit).clamp(0.0, 1.0);
  return (1 - usedRatio).clamp(0.0, 1.0);
}

String voucherUsageText(SellerVoucherViewData voucher) {
  final usageLimit = voucher.usageLimit ?? 0;
  final usageCount = voucher.usageCount ?? 0;
  if (usageLimit <= 0) return 'Không giới hạn';
  final usedRatio = (usageCount / usageLimit).clamp(0.0, 1.0);
  return 'Đã dùng: $usageCount/$usageLimit (${(usedRatio * 100).toStringAsFixed(1)}%)';
}
