import '../../domain/entities/voucher.dart';

class VoucherModel {
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

  const VoucherModel({
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

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic source) {
      if (source == null) return null;
      return DateTime.tryParse(source.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return VoucherModel(
      id: int.tryParse((json['id'] ?? json['voucherId'] ?? json['voucher_id'] ?? '').toString()) ?? 0,
      storeId:
          int.tryParse((json['sellerId'] ?? json['seller_id'] ?? json['storeId'] ?? json['store_id'] ?? '').toString()) ??
              0,
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      discountType: parseVoucherDiscountType(json['discountType']?.toString()),
      discountValue: parseDouble(json['discountValue']) ?? 0,
      minOrderValue: parseDouble(json['minOrderValue']),
      maxDiscount: parseDouble(json['maxDiscount']),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      usageLimit: parseInt(json['usageLimit']),
      usageCount: parseInt(json['usageCount'] ?? json['usedCount']) ?? 0,
      status: parseVoucherStatus(json['status']?.toString()),
      isActive: (json['isActive'] as bool?) ?? (json['active'] as bool?) ?? false,
      isCreatedByAdmin: (json['isCreatedByAdmin'] as bool?) ?? false,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Voucher toEntity() {
    return Voucher(
      id: id,
      storeId: storeId,
      code: code,
      title: title,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      minOrderValue: minOrderValue,
      maxDiscount: maxDiscount,
      startDate: startDate,
      endDate: endDate,
      usageLimit: usageLimit,
      usageCount: usageCount,
      status: status,
      isActive: isActive,
      isCreatedByAdmin: isCreatedByAdmin,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'code': code,
      'title': title,
      'description': description,
      'discountType': voucherDiscountTypeToApiValue(discountType),
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'maxDiscount': maxDiscount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'status': voucherStatusToApiValue(status),
      'isActive': isActive,
      'isCreatedByAdmin': isCreatedByAdmin,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
