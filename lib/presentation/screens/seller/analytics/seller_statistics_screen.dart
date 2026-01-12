import 'dart:math' as math;

import 'package:datn_foodecommerce_flutter_app/domain/entities/sales_stats.dart';
import 'package:datn_foodecommerce_flutter_app/domain/entities/top_product_stat.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utils/currency_formatter.dart';
import '../../seller/products/widgets/product_theme.dart';
import 'seller_statistics_view_model.dart';

class SellerStatisticsScreen extends StatefulWidget {
  final int storeId;
  final String? storeName;

  const SellerStatisticsScreen({super.key, required this.storeId, this.storeName});

  @override
  State<SellerStatisticsScreen> createState() => _SellerStatisticsScreenState();
}

class _SellerStatisticsScreenState extends State<SellerStatisticsScreen> {
  late final SellerStatisticsViewModel _viewModel = GetIt.I<SellerStatisticsViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.load(storeId: widget.storeId);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SellerStatisticsViewModel>.value(
      value: _viewModel,
      child: Consumer<SellerStatisticsViewModel>(
        builder: (_, vm, __) {
          final state = vm.state;
          final stats = state.stats;
          final revenue = stats?.totalRevenue ?? 0;
          final orders = stats?.totalOrders ?? 0;
          return Scaffold(
            backgroundColor: sellerBackground,
            appBar: AppBar(
              backgroundColor: const Color(0xFFFF7A30),
              surfaceTintColor: const Color(0xFFFF7A30),
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Thống kê'),
              centerTitle: false,
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: sellerAccent,
                onRefresh: vm.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _PeriodTabs(
                      selected: state.period,
                      onSelected: (p) => vm.changePeriod(p),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Doanh thu',
                            value: formatCurrency(revenue, suffix: '₫'),
                            subtitle: stats?.period.toUpperCase() ?? '',
                            color: const Color(0xFFF2F6FF),
                            icon: Icons.payments_rounded,
                            iconColor: const Color(0xFF2F80ED),
                            loading: state.isLoadingStats,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Đơn hàng',
                            value: orders.toString(),
                            subtitle: stats?.period.toUpperCase() ?? '',
                            color: const Color(0xFFFFF2E8),
                            icon: Icons.receipt_long_rounded,
                            iconColor: const Color(0xFFFF7A30),
                            loading: state.isLoadingStats,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'Doanh thu theo ngày',
                      isLoading: state.isLoadingStats,
                      points: stats?.points ?? const [],
                    ),
                    const SizedBox(height: 16),
                    _TopProductsCard(
                      products: state.topProducts,
                      isLoading: state.isLoadingTopProducts,
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: state.error!),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _PeriodTabs({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('daily', 'Ngày'),
      ('weekly', 'Tuần'),
      ('monthly', 'Tháng'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(item.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected == item.$1 ? const Color(0xFFFF7A30) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected == item.$1 ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final bool loading;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted)),
                const SizedBox(height: 4),
                loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                      ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final bool isLoading;
  final List<SalesDataPoint> points;

  const _ChartCard({required this.title, required this.isLoading, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (isLoading)
            const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
          else if (points.isEmpty)
            SizedBox(
              height: 160,
              child: Center(
                child: Text('Chưa có dữ liệu', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted)),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: _LineChart(points: points),
            ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<SalesDataPoint> points;
  const _LineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = points.map((e) => e.revenue).reduce(math.max).toDouble();
    final interval = _calcInterval(maxRevenue);
    final minY = 0.0;
    final maxY = maxRevenue + interval;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFFE5E7EB),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          getDrawingVerticalLine: (_) => const FlLine(
            color: Color(0xFFE5E7EB),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: interval,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  // Hiển thị đơn vị nghìn: 60.000 -> 60
                  NumberFormat.decimalPattern('vi').format((value / 1000).round()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final index = value.round();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _formatLabel(points[index].label),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            getTooltipItems: (items) => items.map((spot) {
              final p = points[spot.x.toInt()];
              return LineTooltipItem(
                '${_formatLabel(p.label)}\n${formatCurrency(p.revenue, suffix: '₫')}',
                const TextStyle(color: Color(0xFFFF6E40), fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].revenue.toDouble()),
            ],
            isCurved: true,
            color: const Color(0xFFFF6E40),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeColor: const Color(0xFFFF6E40),
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFF6E40).withOpacity(0.24),
                  const Color(0xFFFF6E40).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calcInterval(double maxY) {
    if (maxY <= 0) return 1;
    final rough = maxY / 4;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final normalized = rough / magnitude;
    double step;
    if (normalized < 1.5) {
      step = 1;
    } else if (normalized < 3) {
      step = 2;
    } else if (normalized < 7) {
      step = 5;
    } else {
      step = 10;
    }
    return step * magnitude;
  }

  String _formatLabel(String label) {
    final parsed = DateTime.tryParse(label);
    if (parsed != null) {
      const weekdayMap = {
        DateTime.monday: 'T2',
        DateTime.tuesday: 'T3',
        DateTime.wednesday: 'T4',
        DateTime.thursday: 'T5',
        DateTime.friday: 'T6',
        DateTime.saturday: 'T7',
        DateTime.sunday: 'CN',
      };
      return weekdayMap[parsed.weekday] ?? label;
    }
    if (label.length > 6) return label.substring(label.length - 5);
    return label;
  }
}

class _TopProductsCard extends StatelessWidget {
  final List<TopProductStat> products;
  final bool isLoading;

  const _TopProductsCard({required this.products, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sản phẩm bán chạy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (isLoading)
            const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          else if (products.isEmpty)
            Text('Chưa có dữ liệu', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted))
          else
            Column(
              children: [
                for (int i = 0; i < products.length; i++) ...[
                  if (i > 0) const Divider(height: 18),
                  _TopProductTile(index: i + 1, product: products[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final int index;
  final TopProductStat product;

  const _TopProductTile({required this.index, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: sellerAccentSoft,
          child: Text(index.toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: sellerAccent)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${product.soldCount} đã bán', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted)),
            ],
          ),
        ),
        Text(formatCurrency(product.revenue, suffix: '₫'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFFFF7A30))),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
