class CreateAddressInput {
  final String userId;
  final String receiver;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;

  const CreateAddressInput({
    required this.userId,
    required this.receiver,
    required this.phone,
    required this.address,
    this.latitude = 0,
    this.longitude = 0,
  });

  Map<String, dynamic> toJson() => {
        'receiver': receiver,
        'phone': phone,
        'address': address,
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
      };
}

