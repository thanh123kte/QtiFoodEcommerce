class UpdateAddressInput {
  final String id;
  final String receiver;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const UpdateAddressInput({
    required this.id,
    required this.receiver,
    required this.phone,
    required this.address,
    this.latitude = 0,
    this.longitude = 0,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'receiver': receiver,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };
}

