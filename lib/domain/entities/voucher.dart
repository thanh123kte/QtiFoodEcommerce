enum VoucherDiscountType {
  percentage,
  fixedAmount,
  unknown,
}

enum VoucherStatus {
  active,
  inactive,
  scheduled,
  expired,
  draft,
  unknown,
}

VoucherDiscountType parseVoucherDiscountType(String? value) {
  switch (value?.toUpperCase()) {
    case 'PERCENTAGE':
      return VoucherDiscountType.percentage;
    case 'FIXED':
    case 'FIXED_AMOUNT':
    case 'AMOUNT':
      return VoucherDiscountType.fixedAmount;
    default:
      return VoucherDiscountType.unknown;
  }
}

String voucherDiscountTypeToApiValue(VoucherDiscountType type) {
  switch (type) {
    case VoucherDiscountType.percentage:
      return 'PERCENTAGE';
    case VoucherDiscountType.fixedAmount:
      return 'FIXED_AMOUNT';
    case VoucherDiscountType.unknown:
      return 'UNKNOWN';
  }
}

VoucherStatus parseVoucherStatus(String? value) {
  switch (value?.toUpperCase()) {
    case 'ACTIVE':
      return VoucherStatus.active;
    case 'INACTIVE':
      return VoucherStatus.inactive;
    case 'SCHEDULED':
    case 'UPCOMING':
      return VoucherStatus.scheduled;
    case 'EXPIRED':
      return VoucherStatus.expired;
    case 'DRAFT':
      return VoucherStatus.draft;
    default:
      return VoucherStatus.unknown;
  }
}

String voucherStatusToApiValue(VoucherStatus status) {
  switch (status) {
    case VoucherStatus.active:
      return 'ACTIVE';
    case VoucherStatus.inactive:
      return 'INACTIVE';
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

class Voucher {
  final int id;
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
  final int? usageCount;
  final VoucherStatus status;
  final bool isActive;
  final bool isCreatedByAdmin;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Voucher({
    required this.id,
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
    this.usageCount,
    required this.status,
    required this.isActive,
    required this.isCreatedByAdmin,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });
}
