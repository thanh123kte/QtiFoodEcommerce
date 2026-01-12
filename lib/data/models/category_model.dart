import '../../config/server_config.dart';
import '../../domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: resolveServerAssetUrl(json['imageUrl'] as String? ?? json['image_url'] as String?),
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool?,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  FatherCategory toEntity() => FatherCategory(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static DateTime? _parseDate(dynamic source) {
    if (source == null) return null;
    if (source is DateTime) return source;
    return DateTime.tryParse(source.toString());
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
