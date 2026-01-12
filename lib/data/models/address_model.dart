import '../../domain/entities/address.dart';

class AddressModel {
  final String id;
  final String userId;
  final String receiver;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.receiver,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: (json['id'] ?? json['address_id'] ?? '').toString(),
        userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
        receiver: json['receiver'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        latitude: json['latitude'] == null ? null : (json['latitude'] as num).toDouble(),
        longitude: json['longitude'] == null ? null : (json['longitude'] as num).toDouble(),
        isDefault: (json['isDefault'] ?? json['is_default']) as bool? ?? false,
        isDeleted: (json['isDeleted'] ?? json['is_deleted'] ?? false) as bool,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'receiver': receiver,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
        'isDeleted': isDeleted,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  Address toEntity() => Address(
        id: id,
        userId: userId,
        receiver: receiver,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
