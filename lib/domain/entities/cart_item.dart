class CartItem {
  final String id;
  final String customerId;
  final CartItemProduct product;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartItem({
    required this.id,
    required this.customerId,
    required this.product,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  CartItem copyWith({
    String? id,
    String? customerId,
    CartItemProduct? product,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get unitPrice => product.discountPrice ?? product.price;

  double get totalPrice => unitPrice * quantity;
}

class CartItemProduct {
  final String id;
  final String storeId;
  final String name;
  final String? imageUrl;
  final double price;
  final double? discountPrice;

  const CartItemProduct({
    required this.id,
    required this.storeId,
    required this.name,
    this.imageUrl,
    required this.price,
    this.discountPrice,
  });

  CartItemProduct copyWith({
    String? id,
    String? storeId,
    String? name,
    String? imageUrl,
    double? price,
    double? discountPrice,
  }) {
    return CartItemProduct(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
    );
  }
}
