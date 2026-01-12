class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final String? name;
  final String? imageUrl;
  final double? originalPrice;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.name,
    this.imageUrl,
    this.originalPrice,
  });
}
