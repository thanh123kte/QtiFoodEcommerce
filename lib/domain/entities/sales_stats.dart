class SalesStats {
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalOrders;
  final num totalRevenue;
  final int storeViewCount;
  final int storeLikeCount;
  final List<SalesDataPoint> points;

  const SalesStats({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
    required this.totalRevenue,
    required this.storeViewCount,
    required this.storeLikeCount,
    this.points = const [],
  });
}

class SalesDataPoint {
  final String label;
  final num revenue;
  final int orders;

  const SalesDataPoint({
    required this.label,
    required this.revenue,
    required this.orders,
  });
}
