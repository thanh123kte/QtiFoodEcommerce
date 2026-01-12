class Address {
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

  const Address({
    required this.id,
    required this.userId,
    required this.receiver,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });
}
