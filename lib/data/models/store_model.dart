import '../../config/server_config.dart';
import '../../domain/entities/store.dart';

class StoreModel {
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
  final StoreDayTimeModel? openTime;
  final StoreDayTimeModel? closeTime;
  final String? status;
  final String? opStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreModel({
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

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final open = json['openTime'] ?? json['open_time'];
    final close = json['closeTime'] ?? json['close_time'];
    return StoreModel(
      id: _asInt(json['id'] ?? json['store_id']),
      ownerId: _asString(json['ownerId'] ?? json['owner_id'] ?? ''),
      name: _asString(json['name']),
      description: _asString(json['description']),
      address: _asString(json['address']),
      latitude: json['latitude'] == null ? null : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] == null ? null : (json['longitude'] as num).toDouble(),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      imageUrl: resolveServerAssetUrl(json['imageUrl'] as String? ?? json['image_url'] as String?) ?? '',
      status: json['status'] as String?,
      opStatus: json['opStatus'] as String?,
      openTime: StoreDayTimeModel.tryParse(open),
      closeTime: StoreDayTimeModel.tryParse(close),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Store toEntity() => Store(
        id: id,
        ownerId: ownerId,
        name: name,
        address: address,
        description: description,
        latitude: latitude,
        longitude: longitude,
        phone: phone,
        email: email,
        imageUrl: imageUrl,
        openTime: openTime?.toEntity(),
        closeTime: closeTime?.toEntity(),
        status: status,
        opStatus: opStatus,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'status': status,
      'opStatus': opStatus,
      'openTime': openTime?.toJson(),
      'closeTime': closeTime?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static String _asString(dynamic source) {
    if (source == null) return '';
    if (source is String) return source;
    return source.toString();
  }

  static int _asInt(dynamic source) {
    if (source == null) return 0;
    if (source is int) return source;
    if (source is num) return source.toInt();
    return int.tryParse(source.toString()) ?? 0;
  }
}

class StoreDayTimeModel {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  StoreDayTimeModel({
    required this.hour,
    required this.minute,
    required this.second,
    required this.nano,
  });

  static StoreDayTimeModel? tryParse(dynamic source) {
    if (source == null) return null;
    if (source is StoreDayTimeModel) return source;
    if (source is Map<String, dynamic>) {
      return StoreDayTimeModel(
        hour: (source['hour'] as num?)?.toInt() ?? 0,
        minute: (source['minute'] as num?)?.toInt() ?? 0,
        second: (source['second'] as num?)?.toInt() ?? 0,
        nano: (source['nano'] as num?)?.toInt() ?? 0,
      );
    }
    if (source is String) {
      String sanitized = source;
      if (sanitized.contains('T')) {
        sanitized = sanitized.substring(sanitized.lastIndexOf('T') + 1);
      } else if (sanitized.contains(' ')) {
        sanitized = sanitized.substring(sanitized.lastIndexOf(' ') + 1);
      }
      final timePart = sanitized.split('.').first;
      final parts = timePart.split(':');
      int read(int index, int max) {
        if (index >= parts.length) return 0;
        final value = int.tryParse(parts[index]);
        if (value == null) return 0;
        if (value < 0) return 0;
        if (value > max) return max;
        return value;
      }

      return StoreDayTimeModel(
        hour: read(0, 23),
        minute: read(1, 59),
        second: read(2, 59),
        nano: 0,
      );
    }
    return null;
  }

  StoreDayTime toEntity() => StoreDayTime(
        hour: hour,
        minute: minute,
        second: second,
        nano: nano,
      );

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'second': second,
      'nano': nano,
    };
  }
}
