class Order {
  final int id;
  final String customerId;
  final int storeId;
  final double totalAmount;
  final double shippingFee;
  final String? shippingAddressId;
  final int? adminVoucherId;
  final int? sellerVoucherId;
  final String? adminVoucherTitle;
  final String? sellerVoucherTitle;
  final String paymentMethod;
  final String? note;
  final DateTime? expectedDeliveryTime;
  final DateTime? createdAt;
  final String? status;
  final String? storeName;
  final double? adminVoucherDiscount;
  final double? sellerVoucherDiscount;
  final String? customerName;

  const Order({
    required this.id,
    required this.customerId,
    required this.storeId,
    required this.totalAmount,
    required this.shippingFee,
    this.shippingAddressId,
    this.adminVoucherId,
    this.sellerVoucherId,
    this.adminVoucherTitle,
    this.sellerVoucherTitle,
    required this.paymentMethod,
    this.note,
    this.expectedDeliveryTime,
    this.createdAt,
    this.status,
    this.storeName,
    this.adminVoucherDiscount,
    this.sellerVoucherDiscount,
    this.customerName,
  });

  Order copyWith({
    int? id,
    String? customerId,
    String? storeId,
    double? totalAmount,
    double? shippingFee,
    String? shippingAddressId,
    int? adminVoucherId,
    int? sellerVoucherId,
    String? adminVoucherTitle,
    String? sellerVoucherTitle,
    double? adminVoucherDiscount,
    double? sellerVoucherDiscount,
    String? paymentMethod,
    String? note,
    DateTime? expectedDeliveryTime,
    DateTime? createdAt,
    String? status,
    String? storeName,
    String? customerName,
  }) {
    return Order(
      id: this.id,
      customerId: customerId ?? this.customerId,
      storeId: this.storeId,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      shippingAddressId: shippingAddressId ?? this.shippingAddressId,
      adminVoucherId: adminVoucherId,
      sellerVoucherId: sellerVoucherId ,
      adminVoucherTitle: adminVoucherTitle ?? this.adminVoucherTitle,
      sellerVoucherTitle: sellerVoucherTitle ?? this.sellerVoucherTitle,
      adminVoucherDiscount: adminVoucherDiscount ?? this.adminVoucherDiscount,
      sellerVoucherDiscount: sellerVoucherDiscount ?? this.sellerVoucherDiscount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      expectedDeliveryTime: expectedDeliveryTime ?? this.expectedDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      storeName: storeName ?? this.storeName,
      customerName: customerName ?? this.customerName,
    );
  }
}
