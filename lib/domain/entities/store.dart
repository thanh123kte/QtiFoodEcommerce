class Store {
  final int id;
  final String ownerId;
  final String name;
  final String address;
  final String description;
  final double? latitude;
  final double? longitude;
  final String phone;
  final String email;
  final String imageUrl;
  final StoreDayTime? openTime;
  final StoreDayTime? closeTime;
  final String? status;
  final String? opStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Store({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.description,
    this.latitude,
    this.longitude,
    required this.phone,
    required this.email,
    required this.imageUrl,
    this.openTime,
    this.closeTime,
    this.status,
    this.opStatus,
    this.createdAt,
    this.updatedAt,
  });
}

class StoreDayTime {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  const StoreDayTime({
    required this.hour,
    required this.minute,
    required this.second,
    required this.nano,
  });

  String toLocalTimeString() {
    int clamp(int value, int max) {
      if (value < 0) return 0;
      if (value > max) return max;
      return value;
    }

    final h = clamp(hour, 23).toString().padLeft(2, '0');
    final m = clamp(minute, 59).toString().padLeft(2, '0');
    final s = clamp(second, 59).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
