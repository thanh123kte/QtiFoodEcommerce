import '../../domain/entities/store_category.dart';

class StoreCategoryModel {
  final int id;
  final int storeId;
  final String name;
  final String? description;
  final int parentCategoryId;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreCategoryModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    required this.parentCategoryId,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) {
    return StoreCategoryModel(
      id: (json['id'] ?? json['categoryId'] ?? json['category_id'] ?? 0) as int,
      storeId: (json['storeId'] ?? json['store_id'] ?? 0) as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      parentCategoryId: (json['categoryId'] ?? json['category_id'])  ,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  StoreCategory toEntity() => StoreCategory(
        id: id,
        storeId: storeId,
        name: name,
        description: description,
        parentCategoryId: parentCategoryId,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'categoryId': parentCategoryId,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
