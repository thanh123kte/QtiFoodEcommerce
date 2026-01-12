import 'package:flutter/foundation.dart';

import '../../../../domain/entities/sales_stats.dart';
import '../../../../domain/entities/top_product_stat.dart';
import '../../../../domain/usecases/order/get_store_sales_stats.dart';
import '../../../../domain/usecases/order/get_store_top_products.dart';

class SellerStatisticsState {
  final bool isLoadingStats;
  final bool isLoadingTopProducts;
  final SalesStats? stats;
  final List<TopProductStat> topProducts;
  final String period;
  final String? error;

  const SellerStatisticsState({
    required this.isLoadingStats,
    required this.isLoadingTopProducts,
    required this.stats,
    required this.topProducts,
    required this.period,
    required this.error,
  });

  factory SellerStatisticsState.initial() => const SellerStatisticsState(
        isLoadingStats: false,
        isLoadingTopProducts: false,
        stats: null,
        topProducts: <TopProductStat>[],
        period: 'daily',
        error: null,
      );

  SellerStatisticsState copyWith({
    bool? isLoadingStats,
    bool? isLoadingTopProducts,
    SalesStats? stats,
    List<TopProductStat>? topProducts,
    String? period,
    Object? error = _noChange,
  }) {
    return SellerStatisticsState(
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingTopProducts: isLoadingTopProducts ?? this.isLoadingTopProducts,
      stats: stats ?? this.stats,
      topProducts: topProducts ?? this.topProducts,
      period: period ?? this.period,
      error: error == _noChange ? this.error : error as String?,
    );
  }

  static const _noChange = Object();
}

class SellerStatisticsViewModel extends ChangeNotifier {
  final GetStoreSalesStats _getStoreSalesStats;
  final GetStoreTopProducts _getStoreTopProducts;

  SellerStatisticsViewModel(this._getStoreSalesStats, this._getStoreTopProducts);

  SellerStatisticsState _state = SellerStatisticsState.initial();
  SellerStatisticsState get state => _state;

  int? _storeId;

  Future<void> load({required int storeId, bool forceRefresh = false}) async {
    _storeId = storeId;
    final id = _storeId;
    if (id == 0) {
      _state = _state.copyWith(error: 'Khong tim thay cua hang');
      notifyListeners();
      return;
    }
    if (_state.isLoadingStats && !forceRefresh) return;
    await Future.wait([
      _fetchStats(id!, _state.period),
      _fetchTopProducts(id),
    ]);
  }

  Future<void> changePeriod(String period) async {
    if (period == _state.period) return;
    _state = _state.copyWith(period: period);
    notifyListeners();
    final id = _storeId;
    if (id == 0) return;
    await _fetchStats(id!, period);
  }

  Future<void> refresh() async {
    if (_storeId == null) return;
    await load(storeId: _storeId!, forceRefresh: true);
  }

  Future<void> _fetchStats(int storeId, String period) async {
    _state = _state.copyWith(isLoadingStats: true, error: null);
    notifyListeners();

    final result = await _getStoreSalesStats(storeId: storeId, period: period);
    result.when(
      ok: (data) {
        _state = _state.copyWith(stats: data, isLoadingStats: false, error: null);
      },
      err: (message) {
        _state = _state.copyWith(isLoadingStats: false, error: message);
      },
    );
    notifyListeners();
  }

  Future<void> _fetchTopProducts(int storeId) async {
    _state = _state.copyWith(isLoadingTopProducts: true);
    notifyListeners();

    final result = await _getStoreTopProducts(storeId);
    result.when(
      ok: (data) {
        _state = _state.copyWith(topProducts: data, isLoadingTopProducts: false);
      },
      err: (_) {
        _state = _state.copyWith(isLoadingTopProducts: false);
      },
    );
    notifyListeners();
  }
}
