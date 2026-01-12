import 'voucher.dart';

class CreateVoucherInput {
  final int storeId;
  final String code;
  final String title;
  final String? description;
  final VoucherDiscountType discountType;
  final double discountValue;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final VoucherStatus status;
  final bool isActive;

  const CreateVoucherInput({
    required this.storeId,
    required this.code,
    required this.title,
    this.description,
    this.discountType = VoucherDiscountType.percentage,
    required this.discountValue,
    this.minOrderValue,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.status = VoucherStatus.active,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    final computedMaxDiscount =
        discountType == VoucherDiscountType.fixedAmount ? discountValue : maxDiscount;
    return {
      'storeId': storeId,
      'code': code,
      'title': title,
      'description': description,
      'discountType': voucherDiscountTypeToApiValue(discountType),
      'discountValue': discountValue,
      'minOrderValue': minOrderValue ?? 0,
      'maxDiscount': computedMaxDiscount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'usageLimit': usageLimit ?? 0,
      'status': voucherStatusToApiValue(status),
      'isActive': isActive,
      'isCreatedByAdmin': false,
    };
  }
}

class UpdateVoucherInput {
  final int storeId;
  final String code;
  final String title;
  final String? description;
  final VoucherDiscountType discountType;
  final double discountValue;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final VoucherStatus status;
  final bool isActive;

  const UpdateVoucherInput({
    required this.storeId,
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    required this.status,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    final computedMaxDiscount =
        discountType == VoucherDiscountType.fixedAmount ? discountValue : maxDiscount;
    return {
      'storeId': storeId,
      'code': code,
      'title': title,
      'description': description,
      'discountType': voucherDiscountTypeToApiValue(discountType),
      'discountValue': discountValue,
      'minOrderValue': minOrderValue ?? 0,
      'maxDiscount': computedMaxDiscount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'usageLimit': usageLimit ?? 0,
      'status': voucherStatusToApiValue(status),
      'isActive': isActive,
      'isCreatedByAdmin': false,
    };
  }
}
