import '../../domain/entities/sales_stats.dart';

class SalesStatsModel {
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalOrders;
  final num totalRevenue;
  final int storeViewCount;
  final int storeLikeCount;
  final List<SalesDataPoint> points;

  const SalesStatsModel({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
    required this.totalRevenue,
    required this.storeViewCount,
    required this.storeLikeCount,
    this.points = const [],
  });

  factory SalesStatsModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    List<SalesDataPoint> parsePoints() {
      final candidate = json['points'] ??
          json['dataPoints'] ??
          json['dailyStats'] ??
          json['series'] ??
          json['stats'] ??
          json['chart'] ??
          json['chartData'] ??
          json['revenueByDate'] ??
          json['salesByDate'] ??
          json['items'];

      List<SalesDataPoint> fromList(List list) {
        return list
            .whereType<Map>()
            .map((e) {
              final label = (e['label'] ?? e['date'] ?? e['day'] ?? e['period'] ?? '').toString();
              num revenue = 0;
              int orders = 0;
              final revRaw = e['revenue'] ?? e['totalRevenue'] ?? e['amount'] ?? e['value'];
              if (revRaw is num) {
                revenue = revRaw;
              } else if (revRaw != null) {
                revenue = num.tryParse(revRaw.toString()) ?? 0;
              }
              final ordRaw = e['orders'] ?? e['totalOrders'] ?? e['count'] ?? e['orderCount'];
              if (ordRaw is int) {
                orders = ordRaw;
              } else if (ordRaw is num) {
                orders = ordRaw.toInt();
              } else if (ordRaw != null) {
                orders = int.tryParse(ordRaw.toString()) ?? 0;
              }
              return SalesDataPoint(label: label.isNotEmpty ? label : '-', revenue: revenue, orders: orders);
            })
            .whereType<SalesDataPoint>()
            .toList();
      }

      if (candidate is List) {
        return fromList(candidate);
      }

      // Handle shape: { labels: [...], revenues: [...], orders: [...] }
      if (candidate is Map) {
        final labels = (candidate['labels'] ?? candidate['dates']) as List?;
        final revenues = (candidate['revenues'] ?? candidate['revenue']) as List?;
        final orders = (candidate['orders'] ?? candidate['orderCounts']) as List?;
        if (labels != null && revenues != null && labels.length == revenues.length) {
          return List.generate(labels.length, (i) {
            final label = labels[i]?.toString() ?? '-';
            final revRaw = revenues[i];
            final ordRaw = orders != null && i < orders.length ? orders[i] : null;
            final rev = revRaw is num ? revRaw : num.tryParse(revRaw?.toString() ?? '') ?? 0;
            final ord = ordRaw is num ? ordRaw.toInt() : int.tryParse(ordRaw?.toString() ?? '') ?? 0;
            return SalesDataPoint(label: label, revenue: rev, orders: ord);
          });
        }
      }

      return const [];
    }

    return SalesStatsModel(
      period: (json['period'] ?? json['type'] ?? '').toString(),
      startDate: parseDate(json['startDate'] ?? json['start_date']),
      endDate: parseDate(json['endDate'] ?? json['end_date']),
      totalOrders: (json['totalOrders'] ?? json['orders'] ?? json['orderCount'] ?? 0) as int,
      totalRevenue: json['totalRevenue'] ?? json['revenue'] ?? json['total_amount'] ?? 0,
      storeViewCount: (json['storeViewCount'] ?? json['views'] ?? json['viewCount'] ?? 0) as int,
      storeLikeCount: (json['storeLikeCount'] ?? json['likes'] ?? json['favoriteCount'] ?? 0) as int,
      points: parsePoints(),
    );
  }

  SalesStats toEntity() {
    return SalesStats(
      period: period,
      startDate: startDate,
      endDate: endDate,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      storeViewCount: storeViewCount,
      storeLikeCount: storeLikeCount,
      points: points,
    );
  }
}
