import '../../config/server_config.dart';
import '../../domain/entities/banner.dart';

class BannerModel {
  final int id;
  final String title;
  final String imageUrl;
  final String description;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      imageUrl: resolveServerAssetUrl(
            json['imageUrl'] as String? ?? json['image_url'] as String?,
          ) ??
          '',
      description: _asString(json['description'] ?? json['desc']),
      status: _asString(json['status']),
      startDate: _parseDate(json['startDate'] ?? json['start_date']),
      endDate: _parseDate(json['endDate'] ?? json['end_date']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  BannerEntity toEntity() => BannerEntity(
        id: id,
        title: title,
        imageUrl: imageUrl,
        description: description,
        status: status,
        startDate: startDate,
        endDate: endDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
