import 'package:datn_foodecommerce_flutter_app/domain/entities/product.dart';
import 'package:datn_foodecommerce_flutter_app/domain/entities/store_category.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/wishlist/remove_store_from_wishlist.dart';
import 'package:flutter/material.dart';

import '../../../../domain/usecases/product/get_store_products.dart';
import '../../../../domain/usecases/store/get_store.dart';
import '../../../../domain/usecases/store/increment_store_view.dart';
import '../../../../domain/usecases/store_category/get_store_categories.dart';
import '../../../../domain/usecases/wishlist/add_store_to_wishlist.dart';
import '../../../../domain/usecases/wishlist/check_store_in_wishlist.dart';
import '../../../../utils/result.dart';
import '../dashboard/customer_dashboard_view_model.dart' show DashboardProductTile;
import 'customer_store_ui_state.dart';
import '../../../../domain/usecases/store_review/get_store_reviews_by_store.dart';
import '../../../../domain/entities/store_review.dart';
import 'package:intl/intl.dart';
import '../../../../config/server_config.dart';

class CustomerStoreDetailViewModel extends ChangeNotifier {
  final GetStore _getStore;
  final IncrementStoreView _incrementStoreView;
  final GetStoreCategories _getStoreCategories;
  final GetProducts _getProducts;
  final AddStoreToWishlist _addStoreToWishlist;
  final RemoveStoreFromWishlist _removeStoreFromWishlist;
  final CheckStoreInWishlist _checkStoreInWishlist;
  final GetStoreReviewsByStore _getStoreReviewsByStore;

  CustomerStoreUiState _state = CustomerStoreUiState.initial();

  CustomerStoreDetailViewModel(
    this._getStore,
    this._incrementStoreView,
    this._getStoreCategories,
    this._getProducts,
    this._addStoreToWishlist,
    this._removeStoreFromWishlist,
    this._checkStoreInWishlist,
    this._getStoreReviewsByStore,
  );

  CustomerStoreUiState get state => _state;

  Future<void> onLoadStore({
    required int storeId,
    String? customerId,
    bool force = false,
  }) async {
    if (_state.isLoading && !force) return;

    _updateState(
      (s) => s.copyWith(
        status: StoreStatus.loading,
        errorMessage: null,
        storeId: storeId,
        customerId: customerId ?? s.customerId,
        isFavorited: false,
        selectedCategoryId: null,
        query: '',
        categories: force ? const <StoreCategoryChipData>[] : s.categories,
        products: force ? const <DashboardProductTile>[] : s.products,
        visibleProducts: force ? const <DashboardProductTile>[] : s.visibleProducts,
      ),
    );

    await _fetchStore();
    await _incrementView();
    await _fetchCategories();
    await _fetchProducts();
    await _fetchWishlistStatus();
    await _fetchReviews();
    _applyFilters(notify: false);

    final hasError = _state.errorMessage != null && _state.errorMessage!.isNotEmpty;
    _updateState((s) => s.copyWith(status: hasError ? StoreStatus.error : StoreStatus.success));
  }

  Future<void> onRefresh() async {
    if (_state.storeId == null) return;
    await onLoadStore(storeId: _state.storeId!, customerId: _state.customerId, force: true);
  }

  Future<Result<void>> onToggleWishlist(String customerId) async {
    if (_state.storeId == null) {
      return const Err('Khong xac dinh duoc cua hang.');
    }
    if (customerId.isEmpty) {
      return const Err('Vui long dang nhap de them yeu thich.');
    }
    if (_state.isFavoriteProcessing) return const Err('Dang xu ly yeu cau truoc.');

    _updateState(
      (s) => s.copyWith(
        isFavoriteProcessing: true,
        customerId: customerId,
      ),
    );

    final result = _state.isFavorited
        ? await _removeStoreFromWishlist(customerId: customerId, storeId: _state.storeId!)
        : await _addStoreToWishlist(customerId: customerId, storeId: _state.storeId!);

    result.when(
      ok: (_) => _updateState((s) => s.copyWith(isFavorited: !s.isFavorited)),
      err: (_) {},
    );

    _updateState((s) => s.copyWith(isFavoriteProcessing: false));
    return result;
  }

  void onSearchQueryChanged(String value) {
    _updateState((s) => s.copyWith(query: value));
    _applyFilters();
  }

  void onCategorySelected(int? categoryId) {
    final newSelection = _state.selectedCategoryId == categoryId ? null : categoryId;
    _updateState((s) => s.copyWith(selectedCategoryId: newSelection));
    _applyFilters();
  }

  Future<String?> validateCategorySelection(int? categoryId) async {
    if (categoryId == null) return null;
    final storeId = _state.storeId;
    if (storeId == null) return 'Khong tim thay cua hang.';

    final result = await _getStoreCategories(storeId);
    String? errorMessage;
    List<StoreCategory> filtered = const [];
    result.when(
      ok: (items) {
        filtered = items.where((item) => item.isDeleted != true).toList();
      },
      err: (message) {
        errorMessage = message;
      },
    );

    if (errorMessage != null) return errorMessage;

    final exists = filtered.any((item) => item.id == categoryId);
    _updateState(
      (s) => s.copyWith(
        categories: List.unmodifiable(
          filtered
              .map(
                (item) => StoreCategoryChipData(
                  id: item.id,
                  name: item.name,
                ),
              )
              .toList(),
        ),
        categoryError: null,
      ),
    );

    if (!exists) {
      _updateState((s) => s.copyWith(selectedCategoryId: null), notify: false);
      _applyFilters();
      return 'Danh muc khong ton tai';
    }

    return null;
  }

  Future<void> _fetchStore() async {
    final storeId = _state.storeId;
    if (storeId == null) return;
    final result = await _getStore(storeId);
    result.when(
      ok: (store) => _updateState(
        (s) => s.copyWith(store: store, errorMessage: null),
      ),
      err: (message) => _updateState(
        (s) => s.copyWith(errorMessage: message),
      ),
    );
  }

  Future<void> _incrementView() async {
    final storeId = _state.storeId;
    if (storeId == null) return;
    await _incrementStoreView(storeId);
  }

  Future<void> _fetchWishlistStatus() async {
    final storeId = _state.storeId;
    final customerId = _state.customerId;
    if (customerId == null || customerId.isEmpty || storeId == null) {
      _updateState((s) => s.copyWith(isFavorited: false));
      return;
    }

    final result = await _checkStoreInWishlist(customerId: customerId, storeId: storeId);
    result.when(
      ok: (value) => _updateState((s) => s.copyWith(isFavorited: value)),
      err: (_) => _updateState((s) => s.copyWith(isFavorited: false)),
    );
  }

  Future<void> _fetchCategories() async {
    final storeId = _state.storeId;
    if (storeId == null) return;

    final result = await _getStoreCategories(storeId);
    result.when(
      ok: (items) {
        final filtered = items.where((item) => item.isDeleted != true).toList();
        _updateState(
          (s) => s.copyWith(
            categories: List.unmodifiable(
              filtered.map(
                (item) => StoreCategoryChipData(
                  id: item.id,
                  name: item.name,
                ),
              ),
            ),
            categoryError: null,
          ),
        );
      },
      err: (message) => _updateState(
        (s) => s.copyWith(
          categoryError: message,
          categories: s.categories.isEmpty ? const <StoreCategoryChipData>[] : s.categories,
        ),
      ),
    );
  }

  Future<void> _fetchProducts() async {
    final storeId = _state.storeId;
    if (storeId == null) return;

    final result = await _getProducts(storeId: storeId);
    result.when(
      ok: (items) => _updateState(
        (s) => s.copyWith(
          products: List.unmodifiable(items.map(_mapProduct).toList()),
          productError: null,
        ),
      ),
      err: (message) => _updateState(
        (s) => s.copyWith(
          productError: message,
          products: s.products.isEmpty ? const <DashboardProductTile>[] : s.products,
        ),
      ),
    );
    _applyFilters(notify: false);
    _applyStoreRatingToProducts();
  }

  Future<void> _fetchReviews() async {
    final storeId = _state.storeId;
    if (storeId == null) return;

    final result = await _getStoreReviewsByStore(storeId);
    result.when(
      ok: (items) {
        final mapped = items.map(_mapReview).toList();
        _updateState((s) => s.copyWith(reviews: mapped), notify: false);
        _applyStoreRatingToProducts();
      },
      err: (_) {
        // Keep existing reviews (likely empty) on error
      },
    );
  }

  StoreReviewViewData _mapReview(StoreReview review) {
    final name = review.customerName.trim();
    final initials = _buildInitials(name.isNotEmpty ? name : 'G');
    final dateLabel = review.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(review.createdAt!.toLocal())
        : '';
    final replyText = review.reply?.trim();
    final replyDateLabel = (review.repliedAt != null && replyText != null && replyText.isNotEmpty)
        ? DateFormat('dd/MM/yyyy').format(review.repliedAt!.toLocal())
        : null;
    final images = review.images
        .map((e) => _resolveImageUrl(e.imageUrl))
        .whereType<String>()
        .toList();
    return StoreReviewViewData(
      initials: initials,
      author: name.isNotEmpty ? name : 'Người dùng',
      comment: review.comment,
      rating: review.rating.toDouble(),
      dateLabel: dateLabel,
      reply: replyText != null && replyText.isNotEmpty ? replyText : null,
      replyDateLabel: replyDateLabel,
      avatarUrl: _resolveImageUrl(review.customerAvatar),
      imageUrls: images,
    );
  }

  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'GU';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
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

    final stats = _storeRatingStats();
    final rating = stats.avg;
    final reviews = stats.count;

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

  _RatingStats _storeRatingStats() {
    final count = _state.reviews.length;
    if (count == 0) return const _RatingStats(0.0, 0);
    final avg = _state.reviews.fold<double>(0, (sum, r) => sum + r.rating) / count;
    return _RatingStats(avg, count);
  }

  void _applyStoreRatingToProducts() {
    final stats = _storeRatingStats();
    if (_state.products.isEmpty) {
      _applyFilters();
      notifyListeners();
      return;
    }

    final updated = _state.products
        .map(
          (p) => DashboardProductTile(
            id: p.id,
            name: p.name,
            description: p.description,
            price: p.price,
            discountPrice: p.discountPrice,
            status: p.status,
            imageUrl: p.imageUrl,
            imageUrls: p.imageUrls,
            categoryId: p.categoryId,
            storeCategoryId: p.storeCategoryId,
            storeId: p.storeId,
            rating: double.parse(stats.avg.toStringAsFixed(1)),
            reviewCount: stats.count,
          ),
        )
        .toList();

    _updateState((s) => s.copyWith(products: updated), notify: false);
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters({bool notify = true}) {
    Iterable<DashboardProductTile> iterable = _state.products;

    final categoryId = _state.selectedCategoryId;
    if (categoryId != null && categoryId > 0) {
      final selectedId = categoryId.toString();
      iterable = iterable.where((product) => product.storeCategoryId == selectedId);
    }

    if (_state.query.trim().isNotEmpty) {
      final keyword = _state.query.trim().toLowerCase();
      iterable = iterable.where(
        (product) =>
            product.name.toLowerCase().contains(keyword) ||
            (product.description?.toLowerCase().contains(keyword) ?? false),
      );
    }

    final filtered = List<DashboardProductTile>.unmodifiable(iterable.toList());
    _updateState((s) => s.copyWith(visibleProducts: filtered), notify: notify);
  }

  void _updateState(
    CustomerStoreUiState Function(CustomerStoreUiState current) builder, {
    bool notify = true,
  }) {
    _state = builder(_state);
    if (notify) notifyListeners();
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = kServerBaseUrl.endsWith('/')
        ? kServerBaseUrl.substring(0, kServerBaseUrl.length - 1)
        : kServerBaseUrl;
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$base$path';
  }
}

class _RatingStats {
  final double avg;
  final int count;
  const _RatingStats(this.avg, this.count);
}
