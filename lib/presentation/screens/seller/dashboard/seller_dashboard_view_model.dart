import 'package:flutter/foundation.dart';

import '../../../../domain/entities/sales_stats.dart';
import '../../../../domain/usecases/order/get_store_sales_stats.dart';
import '../../../../domain/usecases/store/get_store_by_owner.dart';

class SellerDashboardUiState {
  final SalesStats? stats;
  final bool isLoadingStore;
  final bool isLoadingStats;
  final String period;
  final String? error;
  final int? storeId;
  final String? storeName;

  const SellerDashboardUiState({
    this.stats,
    this.isLoadingStore = false,
    this.isLoadingStats = false,
    this.period = 'daily',
    this.error,
    this.storeId,
    this.storeName,
  });

  SellerDashboardUiState copyWith({
    SalesStats? stats,
    bool? isLoadingStore,
    bool? isLoadingStats,
    String? period,
    Object? error = _noChange,
    Object? storeId = _noChange,
    Object? storeName = _noChange,
  }) {
    return SellerDashboardUiState(
      stats: stats ?? this.stats,
      isLoadingStore: isLoadingStore ?? this.isLoadingStore,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      period: period ?? this.period,
      error: error == _noChange ? this.error : error as String?,
      storeId: storeId == _noChange ? this.storeId : storeId as int?,
      storeName: storeName == _noChange ? this.storeName : storeName as String?,
    );
  }

  static const _noChange = Object();
}

class SellerDashboardViewModel extends ChangeNotifier {
  final GetStoreByOwner _getStoreByOwner;
  final GetStoreSalesStats _getStoreSalesStats;

  SellerDashboardViewModel(this._getStoreByOwner, this._getStoreSalesStats);

  SellerDashboardUiState _state = const SellerDashboardUiState();
  SellerDashboardUiState get state => _state;

  Future<void> load(String ownerId) async {
    if (_state.isLoadingStore) return;
    _state = _state.copyWith(isLoadingStore: true, error: null);
    notifyListeners();

    final result = await _getStoreByOwner(ownerId);
    result.when(
      ok: (store) {
        if (store == null) {
          _state = _state.copyWith(
            isLoadingStore: false,
            error: 'Chua tim thay cua hang cho tai khoan nay.',
          );
          notifyListeners();
          return;
        }
        _state = _state.copyWith(
          storeId: store.id,
          storeName: store.name,
        );
      },
      err: (message) {
        _state = _state.copyWith(error: message);
      },
    );

    _state = _state.copyWith(isLoadingStore: false);
    notifyListeners();

    if (_state.storeId != null && _state.error == null) {
      await fetchStats(period: _state.period);
    }
  }

  Future<void> fetchStats({required String period}) async {
    if (_state.storeId == null) return;
    _state = _state.copyWith(period: period, isLoadingStats: true, error: null);
    notifyListeners();

    final result = await _getStoreSalesStats(storeId: _state.storeId!, period: period);
    result.when(
      ok: (data) {
        _state = _state.copyWith(stats: data);
      },
      err: (message) {
        _state = _state.copyWith(error: message);
      },
    );

    _state = _state.copyWith(isLoadingStats: false);
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_state.storeId == null) return;
    await fetchStats(period: _state.period);
  }
}
