import 'package:flutter/material.dart';

import 'customer_dashboard_view_model.dart';

class DashboardFilterResult {
  final int? categoryId;
  final ProductSortOption sortOption;
  final double? minPrice;
  final double? maxPrice;

  const DashboardFilterResult({
    required this.categoryId,
    required this.sortOption,
    this.minPrice,
    this.maxPrice,
  });
}

class PriceTier {
  final String label;
  final double? min;
  final double? max;
  final String display;

  const PriceTier({
    required this.label,
    this.min,
    this.max,
    required this.display,
  });
}

class DashboardFilterUiState {
  final int tabIndex;
  final int? selectedCategoryId;
  final ProductSortOption sortOption;
  final RangeValues range;
  final double maxPriceBound;
  final PriceTier? selectedTier;
  final List<PriceTier> tiers;

  const DashboardFilterUiState({
    required this.tabIndex,
    required this.selectedCategoryId,
    required this.sortOption,
    required this.range,
    required this.maxPriceBound,
    required this.selectedTier,
    required this.tiers,
  });

  DashboardFilterUiState copyWith({
    int? tabIndex,
    int? selectedCategoryId,
    ProductSortOption? sortOption,
    RangeValues? range,
    double? maxPriceBound,
    PriceTier? selectedTier,
    List<PriceTier>? tiers,
    bool clearSelectedTier = false,
  }) {
    return DashboardFilterUiState(
      tabIndex: tabIndex ?? this.tabIndex,
      selectedCategoryId: selectedCategoryId ,
      sortOption: sortOption ?? this.sortOption,
      range: range ?? this.range,
      maxPriceBound: maxPriceBound ?? this.maxPriceBound,
      selectedTier: clearSelectedTier ? null : (selectedTier ?? this.selectedTier),
      tiers: tiers ?? this.tiers,
    );
  }
}

class DashboardFilterViewModel extends ChangeNotifier {
  DashboardFilterUiState _state;

  DashboardFilterUiState get state => _state;

  DashboardFilterViewModel({
    required int? initialCategoryId,
    required ProductSortOption initialSort,
    required double? minPrice,
    required double? maxPrice,
    required double priceBound,
  }) : _state = _buildInitialState(
          initialCategoryId: initialCategoryId,
          initialSort: initialSort,
          minPrice: minPrice,
          maxPrice: maxPrice,
          priceBound: priceBound,
        );

  void setTab(int index) {
    _state = _state.copyWith(tabIndex: index);
    notifyListeners();
  }

  void selectCategory(int? id) {
    _state = _state.copyWith(selectedCategoryId: id);
    notifyListeners();
  }

  void resetFilters() {
    _state = _buildInitialState(
      initialCategoryId: null,
      initialSort: ProductSortOption.none,
      minPrice: null,
      maxPrice: null,
      priceBound: _state.maxPriceBound,
    ).copyWith(tabIndex: 0);
    notifyListeners();
  }

  void setSort(ProductSortOption option) {
    _state = _state.copyWith(sortOption: option);
    notifyListeners();
  }

  void setRange(RangeValues values) {
    final start = values.start.clamp(0, _state.maxPriceBound);
    final end = values.end.clamp(start, _state.maxPriceBound);
    final clamped = RangeValues(start.toDouble(), end.toDouble());
    _state = _state.copyWith(range: clamped, clearSelectedTier: true);
    notifyListeners();
  }

  void selectTier(PriceTier? tier) {
    if (tier == null) {
      _state = _state.copyWith(clearSelectedTier: true);
      notifyListeners();
      return;
    }
    final start = tier.min ?? 0;
    final end = tier.max ?? _state.maxPriceBound;
    _state = _state.copyWith(
      selectedTier: tier,
      range: RangeValues(start, end.clamp(start, _state.maxPriceBound)),
    );
    notifyListeners();
  }

  static double _safeBound(double bound) {
    if (bound.isNaN || bound.isInfinite || bound <= 0) return 2000000;
    return bound < 100000 ? 2000000 : bound;
  }

  static DashboardFilterUiState _buildInitialState({
    required int? initialCategoryId,
    required ProductSortOption initialSort,
    required double? minPrice,
    required double? maxPrice,
    required double priceBound,
  }) {
    final safeBound = _safeBound(priceBound);
    final start = (minPrice ?? 0).clamp(0, safeBound).toDouble();
    final end = (maxPrice ?? safeBound).clamp(start, safeBound).toDouble();
    return DashboardFilterUiState(
      tabIndex: 0,
      selectedCategoryId: initialCategoryId,
      sortOption: initialSort,
      range: RangeValues(start, end),
      maxPriceBound: safeBound,
      selectedTier: null,
      tiers: const [
        PriceTier(label: r'$', min: 0, max: 50000, display: '0 - 50k'),
        PriceTier(label: r'$$', min: 50000, max: 200000, display: '50k - 200k'),
        PriceTier(label: r'$$$', min: 200000, max: 500000, display: '200k - 500k'),
        PriceTier(label: r'$$$$', min: 500000, max: 1500000, display: '500k - 1.5M'),
      ],
    );
  }
}
