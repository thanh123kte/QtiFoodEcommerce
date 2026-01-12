class CreateOrderInput {
  final String customerId;
  final int storeId;
  final int? driverId;
  final int? shippingAddressId;
  final double totalAmount;
  final double shippingFee;
  final int? adminVoucherId;
  final int? sellerVoucherId;
  final String paymentMethod;
  final String? note;
  final List<CreateOrderProductInput> items;

  const CreateOrderInput({
    required this.customerId,
    required this.storeId,
    this.driverId,
    this.shippingAddressId,
    required this.totalAmount,
    required this.shippingFee,
    this.adminVoucherId,
    this.sellerVoucherId,
    this.paymentMethod = 'COD',
    this.note,
    this.items = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'storeId': storeId,
      if (driverId != null) 'driverId': driverId,
      if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
      'totalAmount': totalAmount,
      'shippingFee': shippingFee,
      if (adminVoucherId != null) 'adminVoucherId': adminVoucherId,
      if (sellerVoucherId != null) 'sellerVoucherId': sellerVoucherId,
      'paymentMethod': paymentMethod,
      if (note != null && note!.isNotEmpty) 'note': note,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateOrderProductInput {
  final int productId;
  final int quantity;
  final double price;

  const CreateOrderProductInput({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class CreateOrderItemInput {
  final int orderId;
  final int productId;
  final int quantity;
  final double price;

  const CreateOrderItemInput({
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}
