import '../../config/server_config.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel {
  final String id;
  final String customerId;
  final CartProductModel product;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItemModel({
    required this.id,
    required this.customerId,
    required this.product,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = _extractProductJson(json);
    return CartItemModel(
      id: _readId(json['id'] ?? json['cartItemId'] ?? json['cart_item_id']),
      customerId: _readId(
        json['customerId'] ?? json['customer_id'] ?? json['userId'] ?? json['cartId'] ?? productJson['customerId'],
      ),
      product: CartProductModel.fromJson(productJson),
      quantity: _readInt(json['quantity']) ?? 0,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  CartItem toEntity() {
    return CartItem(
      id: id,
      customerId: customerId,
      product: product.toEntity(),
      quantity: quantity,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? customerId,
    CartProductModel? product,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'quantity': quantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'product': product.toJson(),
    };
  }

  static Map<String, dynamic> _extractProductJson(Map<String, dynamic> json) {
    final product = json['product'];
    if (product is Map<String, dynamic>) {
      return Map<String, dynamic>.from(product);
    }
    return {
      'id': json['productId'] ?? json['product_id'],
      'storeId': json['storeId'] ?? json['store_id'],
      'name': json['productName'] ?? json['name'],
      'price': json['price'],
      'discountPrice': json['discountPrice'] ?? json['discount_price'],
      'imageUrl': json['imageUrl'] ?? json['thumbnail'] ?? json['image'],
      'productImages': json['productImages'] ?? json['images'],
    };
  }

  static String _readId(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class CartProductModel {
  final String id;
  final String storeId;
  final String name;
  final String? imageUrl;
  final double price;
  final double? discountPrice;

  CartProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.imageUrl,
    required this.price,
    this.discountPrice,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    final resolvedImage = resolveServerAssetUrl(
      json['imageUrl'] as String? ??
          json['thumbnail'] as String? ??
          _readFirstImage(json['productImages']) ??
          _readFirstImage(json['images']),
    );
    return CartProductModel(
      id: CartItemModel._readId(json['id'] ?? json['productId'] ?? json['product_id']),
      storeId: CartItemModel._readId(json['storeId'] ?? json['store_id']),
      name: json['name'] as String? ?? json['productName'] as String? ?? '',
      imageUrl: resolvedImage,
      price: _readDouble(json['price']) ?? 0,
      discountPrice: _readDouble(json['discountPrice'] ?? json['discount_price']),
    );
  }

  CartItemProduct toEntity() {
    return CartItemProduct(
      id: id,
      storeId: storeId,
      name: name,
      imageUrl: imageUrl,
      price: price,
      discountPrice: discountPrice,
    );
  }

  CartProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? imageUrl,
    double? price,
    double? discountPrice,
  }) {
    return CartProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'discountPrice': discountPrice,
    };
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _readFirstImage(dynamic value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        return map['imageUrl'] as String? ??
            map['url'] as String? ??
            map['path'] as String?;
      }
      if (first is String) return first;
    }
    return null;
  }
}
