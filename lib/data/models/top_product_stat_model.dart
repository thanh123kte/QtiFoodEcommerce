import '../../domain/entities/top_product_stat.dart';

class TopProductStatModel {
  final int productId;
  final String name;
  final int soldCount;
  final num revenue;

  const TopProductStatModel({
    required this.productId,
    required this.name,
    required this.soldCount,
    required this.revenue,
  });

  factory TopProductStatModel.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    num _asNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      final parsed = num.tryParse(value.toString());
      return parsed ?? 0;
    }

    final name = (json['productName'] ?? json['name'] ?? '').toString();
    return TopProductStatModel(
      productId: _asInt(json['productId'] ?? json['product_id'] ?? json['id']),
      name: name.isNotEmpty ? name : 'San pham',
      soldCount: _asInt(json['totalSold'] ?? json['soldCount'] ?? json['quantity'] ?? json['totalQuantity'] ?? json['sold']),
      revenue: _asNum(json['totalRevenue'] ?? json['revenue'] ?? json['amount']),
    );
  }

  TopProductStat toEntity() {
    return TopProductStat(
      productId: productId,
      name: name,
      soldCount: soldCount,
      revenue: revenue,
    );
  }
}
