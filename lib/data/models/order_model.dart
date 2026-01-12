import '../../domain/entities/order.dart';

class OrderModel {
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
  final double? adminVoucherDiscount;
  final double? sellerVoucherDiscount;
  final String paymentMethod;
  final String? note;
  final DateTime? expectedDeliveryTime;
  final DateTime? createdAt;
  final String? status;
  final String? storeName;
  final String? customerName;

  const OrderModel({
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
    this.adminVoucherDiscount,
    this.sellerVoucherDiscount,
    required this.paymentMethod,
    this.note,
    this.expectedDeliveryTime,
    this.createdAt,
    this.status,
    this.storeName,
    this.customerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic source) {
      if (source == null) return null;
      return DateTime.tryParse(source.toString());
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return OrderModel(
      id: (json['id'] ?? json['orderId'] ?? json['order_id'] ?? 0) as int,
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['customer_name']?.toString(),
      storeId: (json['storeId'] ?? json['store_id'] ?? 0) as int,
      storeName: json['storeName']?.toString() ?? json['store_name']?.toString(),
      totalAmount: parseDouble(json['totalAmount']),
      shippingFee: parseDouble(json['shippingFee']),
      shippingAddressId: (json['shippingAddressId'] ?? json['shipping_address_id'] ?? json['addressId'] ?? json['address_id'])
          ?.toString(),
      adminVoucherId: json['adminVoucherId'],
      sellerVoucherId: json['sellerVoucherId'],
      adminVoucherTitle: json['adminVoucherTitle']?.toString(),
      sellerVoucherTitle: json['sellerVoucherTitle']?.toString(),
      adminVoucherDiscount: json['adminVoucherDiscount'] == null
          ? null
          : parseDouble(json['adminVoucherDiscount']),
      sellerVoucherDiscount: json['sellerVoucherDiscount'] == null
          ? null
          : parseDouble(json['sellerVoucherDiscount']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      note: json['note']?.toString(),
      expectedDeliveryTime: parseDate(json['expectedDeliveryTime']),
      createdAt: parseDate(json['createdAt']),
      status: (json['orderStatus'] ?? json['status'])?.toString(),
    );
  }

  Order toEntity() {
    return Order(
      id: id,
      customerId: customerId,
      customerName: customerName,
      storeId: storeId,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      shippingAddressId: shippingAddressId,
      adminVoucherId: adminVoucherId,
      sellerVoucherId: sellerVoucherId,
      adminVoucherTitle: adminVoucherTitle,
      sellerVoucherTitle: sellerVoucherTitle,
      adminVoucherDiscount: adminVoucherDiscount,
      sellerVoucherDiscount: sellerVoucherDiscount,
      paymentMethod: paymentMethod,
      note: note,
      expectedDeliveryTime: expectedDeliveryTime,
      createdAt: createdAt,
      status: status,
      storeName: storeName,
    );
  }
}
