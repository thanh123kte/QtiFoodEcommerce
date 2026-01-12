import '../../domain/entities/order_item.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final String? name;
  final String? imageUrl;
  final double? originalPrice;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.name,
    this.imageUrl,
    this.originalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return OrderItemModel(
      id: (json['id'] ?? json['orderItemId'] ?? json['order_item_id'] ?? '').toString(),
      orderId: (json['orderId'] ?? json['order_id'] ?? '').toString(),
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      quantity: parseInt(json['quantity']),
      price: parseDouble(json['price']),
      name: json['productName']?.toString() ?? json['name']?.toString(),
      imageUrl: json['productImage']?.toString() ??
          json['imageUrl']?.toString() ??
          (json['product'] is Map ? (json['product']['imageUrl'] ?? json['product']['image_url'])?.toString() : null),
      originalPrice: json['originalPrice'] == null ? null : parseDouble(json['originalPrice']),
    );
  }

  OrderItem toEntity() => OrderItem(
        id: id,
        orderId: orderId,
        productId: productId,
        quantity: quantity,
        price: price,
        name: name,
        imageUrl: imageUrl,
        originalPrice: originalPrice,
      );
}
