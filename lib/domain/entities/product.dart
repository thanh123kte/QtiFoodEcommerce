class Product {
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
  final List<ProductImage> images;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
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
    this.images = const [],
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
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
    List<ProductImage>? images,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
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

}

class ProductImage {
  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final bool? isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductImage({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  ProductImage copyWith({
    String? id,
    String? productId,
    String? productName,
    String? imageUrl,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductImage(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
