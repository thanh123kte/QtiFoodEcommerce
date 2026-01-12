import '../../domain/entities/place_suggestion.dart';

class PlaceSuggestionModel {
  final String id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;

  PlaceSuggestionModel({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) {
    final position = json['position'];
    double? lat;
    double? lng;
    if (position is Map) {
      final posMap = Map<String, dynamic>.from(position);
      final latValue = posMap['lat'];
      final lngValue = posMap['lng'];
      lat = latValue is num ? latValue.toDouble() : null;
      lng = lngValue is num ? lngValue.toDouble() : null;
    }

    final address = json['address'];
    final label = address is Map<String, dynamic> ? address['label'] as String? : null;

    return PlaceSuggestionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      address: label ?? json['title'] as String? ?? '',
      latitude: lat,
      longitude: lng,
    );
  }

  PlaceSuggestion toEntity() => PlaceSuggestion(
        id: id,
        title: title,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
}

