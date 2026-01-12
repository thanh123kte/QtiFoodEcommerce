import 'store.dart';

class UpdateStoreInput {
  final String? name;
  final String? address;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final StoreDayTime? openTime;
  final StoreDayTime? closeTime;

  const UpdateStoreInput({
    this.name,
    this.address,
    this.description,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.imageUrl,
    this.openTime,
    this.closeTime,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    void put(String key, dynamic value) {
      if (value == null) return;
      data[key] = value;
    }

    put('name', name);
    put('address', address);
    put('description', description);
    put('latitude', latitude);
    put('longitude', longitude);
    put('phone', phone);
    put('email', email);
    put('imageUrl', imageUrl);
    if (openTime != null) {
      data['openTime'] = openTime!.toLocalTimeString();
    }
    if (closeTime != null) {
      data['closeTime'] = closeTime!.toLocalTimeString();
    }

    return data;
  }
}
