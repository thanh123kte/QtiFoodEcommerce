import '../../config/server_config.dart';
import '../../domain/entities/nearby_store.dart';

class NearbyStoreModel {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final double distanceKm;
  final String? imageUrl;

  NearbyStoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.imageUrl,
  });

  factory NearbyStoreModel.fromJson(Map<String, dynamic> json) {
    return NearbyStoreModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      address: _asString(json['address']),
      latitude: _asDoubleOrNull(json['latitude']),
      longitude: _asDoubleOrNull(json['longitude']),
      distanceKm: _asDouble(json['distanceKm']),
      imageUrl: resolveServerAssetUrl(
        json['imageUrl'] as String? ?? json['image_url'] as String?,
      ),
    );
  }

  NearbyStore toEntity() => NearbyStore(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm,
        imageUrl: imageUrl,
      );

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

  static double _asDouble(dynamic source) {
    if (source == null) return 0;
    if (source is double) return source;
    if (source is num) return source.toDouble();
    return double.tryParse(source.toString()) ?? 0;
  }

  static double? _asDoubleOrNull(dynamic source) {
    if (source == null) return null;
    if (source is double) return source;
    if (source is num) return source.toDouble();
    return double.tryParse(source.toString());
  }
}
