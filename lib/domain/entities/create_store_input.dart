import 'store.dart';

class CreateStoreInput {
  final String ownerId;
  final String name;
  final String address;
  final String description;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String imageUrl;
  final StoreDayTime openTime;
  final StoreDayTime closeTime;

  const CreateStoreInput({
    required this.ownerId,
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.openTime,
    required this.closeTime,
  });

  Map<String, dynamic> toJson() => {
        'ownerId': ownerId,
        'name': name,
        'address': address,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'imageUrl': imageUrl,
        'openTime': openTime.toLocalTimeString(),
        'closeTime': closeTime.toLocalTimeString(),
      };
}
