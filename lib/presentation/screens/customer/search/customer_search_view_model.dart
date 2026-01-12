import 'package:flutter/material.dart';

import '../../../../domain/entities/search_history.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/product/search_products.dart';
import '../../../../domain/usecases/search_history/get_search_history.dart';
import '../../../../domain/usecases/search_history/save_search_history.dart';
import '../../../screens/customer/dashboard/customer_dashboard_view_model.dart';

class CustomerSearchViewModel extends ChangeNotifier {
  final SearchProducts _searchProducts;
  final GetSearchHistory _getSearchHistory;
  final SaveSearchHistory _saveSearchHistory;

  bool _isLoading = false;
  bool _isHistoryLoading = false;
  String? _error;
  String _query = '';
  List<SearchHistory> _history = const [];
  List<DashboardProductTile> _results = const [];

  bool get isLoading => _isLoading;
  bool get isHistoryLoading => _isHistoryLoading;
  String? get error => _error;
  String get query => _query;
  List<SearchHistory> get history => List.unmodifiable(_history);
  List<DashboardProductTile> get results => List.unmodifiable(_results);

  CustomerSearchViewModel(
    this._searchProducts,
    this._getSearchHistory,
    this._saveSearchHistory,
  );

  Future<void> loadHistory(String? userId) async {
    if (userId == null) {
      _history = const [];
      notifyListeners();
      return;
    }
    _isHistoryLoading = true;
    notifyListeners();
    final result = await _getSearchHistory(userId, limit: 5);
    result.when(
      ok: (items) {
        _history = List.unmodifiable(items.take(5));
      },
      err: (_) {},
    );
    _isHistoryLoading = false;
    notifyListeners();
  }

  Future<void> search({
    required String keyword,
    required String? userId,
  }) async {
    final normalized = keyword.trim();
    _query = normalized;
    if (normalized.isEmpty) {
      _results = const [];
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _searchProducts(keyword: normalized);
    result.when(
      ok: (items) {
        _results = items.map(_mapProduct).toList();
        _error = null;
      },
      err: (message) {
        _results = const [];
        _error = message;
      },
    );
    _isLoading = false;
    notifyListeners();

    if (userId != null) {
      final saveResult = await _saveSearchHistory(userId: userId, keyword: normalized);
      saveResult.when(
        ok: (_) => _upsertHistory(SearchHistory(keyword: normalized, searchedAt: DateTime.now())),
        err: (_) {},
      );
    }
  }

  void _upsertHistory(SearchHistory entry) {
    final normalized = entry.keyword.toLowerCase();
    final deduped = _history.where((item) => item.keyword.toLowerCase() != normalized);
    final merged = [entry, ...deduped];
    merged.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    _history = List.unmodifiable(merged.take(5));
    notifyListeners();
  }

  DashboardProductTile _mapProduct(Product product) {
    String? primaryImage;
    final List<String> imageUrls = [];
    for (final image in product.images) {
      if (image.imageUrl.isNotEmpty) {
        imageUrls.add(image.imageUrl);
      }
      if (image.isPrimary == true && primaryImage == null) {
        primaryImage = image.imageUrl;
      }
    }
    primaryImage ??= imageUrls.isNotEmpty ? imageUrls.first : null;
    final seed = product.id.hashCode.abs();
    final rating = (3.5 + (seed % 15) / 10).clamp(0, 5).toDouble();
    final reviews = 20 + seed % 180;
    return DashboardProductTile(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      status: product.status,
      imageUrl: primaryImage,
      imageUrls: imageUrls,
      categoryId: product.categoryId,
      storeCategoryId: product.storeCategoryId,
      storeId: product.storeId,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviews,
    );
  }
}
