import 'dart:developer' as developer;

import '../../config/server_config.dart';
import '../../domain/entities/product.dart';

class ProductModel {
  final String id;
  final int storeId;
  final String? categoryId;
  final String? storeCategoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String status;
  final String? adminStatus;
  final List<ProductImageModel> images;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.storeId,
    this.categoryId,
    this.storeCategoryId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.status,
    this.adminStatus,
    List<ProductImageModel>? images,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : images = images ?? const [];

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _readId(json['id']),
      storeId: json['storeId'] ?? json['store_id'],
      categoryId: _readNullableId(json['categoryId'] ?? json['category_id']),
      storeCategoryId: _readNullableId(json['storeCategoryId'] ?? json['store_category_id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: _readDouble(json['price']) ?? 0,
      discountPrice: _readDouble(json['discountPrice'] ?? json['discount_price']),
      status: json['status'] as String? ?? 'AVAILABLE',
      adminStatus: json['adminStatus'] as String? ?? json['admin_status'] as String?,
      images: _parseImages(json),
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      storeId: product.storeId,
      categoryId: product.categoryId,
      storeCategoryId: product.storeCategoryId,
      name: product.name,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      status: product.status,
      adminStatus: product.adminStatus,
      images: product.images.map(ProductImageModel.fromEntity).toList(),
      isDeleted: product.isDeleted,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      storeId: storeId,
      categoryId: categoryId,
      storeCategoryId: storeCategoryId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      status: status,
      adminStatus: adminStatus,
      images: images.map((e) => e.toEntity()).toList(),
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  ProductModel copyWith({
    String? id,
    int? storeId,
    String? categoryId,
    String? storeCategoryId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? status,
    String? adminStatus,
    List<ProductImageModel>? images,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      storeCategoryId: storeCategoryId ?? this.storeCategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      status: status ?? this.status,
      adminStatus: adminStatus ?? this.adminStatus,
      images: images ?? this.images,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'categoryId': categoryId,
      'storeCategoryId': storeCategoryId,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'status': status,
      'adminStatus': adminStatus,
      'images': images.map((e) => e.toJson()).toList(),
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static List<ProductImageModel> _parseImages(Map<String, dynamic> json) {
    final raw = json['productImages'] ?? json['images'];
    developer.log(
      'Parsing images for product ${json['id']} -> ${raw is List ? raw.length : 0}',
      name: 'ProductModel',
    );
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => ProductImageModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }
    return const [];
  }

  static String _readId(dynamic source) {
    if (source == null) return '';
    return source.toString();
  }

  static String? _readNullableId(dynamic source) {
    if (source == null) return null;
    final value = source.toString();
    if (value.trim().isEmpty) return null;
    return value;
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class ProductImageModel {
  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final bool? isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductImageModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    final url = resolveServerAssetUrl(
          json['imageUrl'] as String? ?? json['url'] as String?,
        ) ??
        '';
    developer.log(
      'Resolved product image url=$url id=${json['id']} productId=${json['productId'] ?? json['product_id']}',
      name: 'ProductImageModel',
    );
    return ProductImageModel(
      id: ProductModel._readId(json['id']),
      productId: ProductModel._readId(json['productId'] ?? json['product_id']),
      productName: json['productName'] as String? ?? '',
      imageUrl: url,
      isPrimary: json['isPrimary'] as bool?,
      createdAt: ProductModel._parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: ProductModel._parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  factory ProductImageModel.fromEntity(ProductImage image) {
    return ProductImageModel(
      id: image.id,
      productId: image.productId,
      productName: image.productName,
      imageUrl: image.imageUrl,
      isPrimary: image.isPrimary,
      createdAt: image.createdAt,
      updatedAt: image.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'isPrimary': isPrimary,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductImage toEntity() {
    return ProductImage(
      id: id,
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      isPrimary: isPrimary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
