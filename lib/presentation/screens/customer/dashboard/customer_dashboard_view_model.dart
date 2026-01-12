import 'package:flutter/material.dart';

import '../../../../domain/entities/banner.dart';
import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/nearby_store.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/banner/get_banners_by_status.dart';
import '../../../../domain/usecases/category/get_categories.dart';
import '../../../../domain/usecases/product/get_products.dart';
import '../../../../domain/usecases/store/get_nearby_stores.dart';
import '../../../../domain/usecases/store_review/get_store_reviews_by_store.dart';
import '../../../../services/location/location_provider.dart';

class DashboardCategoryChip {
  final int id;
  final String name;
  final String? imageUrl;

  const DashboardCategoryChip({
    required this.id,
    required this.name,
    this.imageUrl,
  });
}

class DashboardBannerData {
  final int id;
  final String title;
  final String imageUrl;
  final String description;

  const DashboardBannerData({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
  });
}

enum ProductSortOption { none, priceAsc, priceDesc }

class DashboardProductTile {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String status;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? categoryId;
  final String? storeCategoryId;
  final int storeId;
  final double rating;
  final int reviewCount;

  const DashboardProductTile({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.status = 'AVAILABLE',
    this.imageUrl,
    this.imageUrls = const [],
    this.categoryId,
    this.storeCategoryId,
    required this.storeId,
    required this.rating,
    required this.reviewCount,
  });
}

class DashboardNearbyStoreTile {
  final int id;
  final String name;
  final String address;
  final double distanceKm;
  final String? imageUrl;

  const DashboardNearbyStoreTile({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    this.imageUrl,
  });
}

class CustomerDashboardViewModel extends ChangeNotifier {
  static _DashboardCache? _cache;

  final GetBannersByStatus _getBannersByStatus;
  final GetCategories _getCategories;
  final GetFeaturedProducts _getFeaturedProducts;
  final GetStoreReviewsByStore _getStoreReviewsByStore;
  final GetNearbyStores _getNearbyStores;
  final LocationProvider _locationProvider;
  final int _pageSize;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isNearbyLoading = false;
  bool _isBannerLoading = false;
  String? _error;
  String? _categoryError;
  String? _nearbyError;
  String? _bannerError;
  int _page = 1;
  String _query = '';
  int? _selectedCategoryId;
  ProductSortOption _sortOption = ProductSortOption.none;
  double? _minPriceFilter;
  double? _maxPriceFilter;
  final Map<int, _StoreRatingStats> _storeRatings = {};
  final Set<int> _storeRatingsLoading = {};

  List<DashboardCategoryChip> _categories = const [];
  final List<DashboardProductTile> _products = [];
  List<DashboardProductTile> _filteredProducts = const [];
  List<DashboardNearbyStoreTile> _nearbyStores = [];
  List<DashboardBannerData> _banners = [];

  static const int _nearbyStoreLimit = 10;

  CustomerDashboardViewModel(
    this._getBannersByStatus,
    this._getCategories,
    this._getFeaturedProducts,
    this._getStoreReviewsByStore,
    this._getNearbyStores,
    this._locationProvider, {
    int pageSize = 10,
  }) : _pageSize = pageSize {
    _restoreCache();
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isNearbyLoading => _isNearbyLoading;
  bool get isBannerLoading => _isBannerLoading;
  String? get error => _error;
  String? get categoryError => _categoryError;
  String? get nearbyError => _nearbyError;
  String? get bannerError => _bannerError;
  String get query => _query;
  int? get selectedCategoryId => _selectedCategoryId;
  ProductSortOption get sortOption => _sortOption;

  List<DashboardCategoryChip> get categories => _categories;
  List<DashboardBannerData> get banners => List.unmodifiable(_banners);
  List<DashboardProductTile> get products => List.unmodifiable(_products);
  List<DashboardProductTile> get visibleProducts => List.unmodifiable(_filteredProducts);
  List<DashboardNearbyStoreTile> get nearbyStores => List.unmodifiable(_nearbyStores);
  List<DashboardNearbyStoreTile> get visibleNearbyStores =>
      List.unmodifiable(_nearbyStores.take(_nearbyStoreLimit).toList());
  bool get hasNearbyMore => _nearbyStores.length > _nearbyStoreLimit;
  double? get minPriceFilter => _minPriceFilter;
  double? get maxPriceFilter => _maxPriceFilter;
  double get maxProductPriceBound {
    if (_products.isEmpty) return 1000000;
    return _products
        .map((p) => p.discountPrice ?? p.price)
        .fold<double>(0, (prev, price) => price > prev ? price : prev)
        .clamp(0, double.infinity);
  }

  Future<void> load({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _nearbyError = null;
      _bannerError = null;
    }
    _error = null;
    _isLoading = true;
    notifyListeners();

    await _loadBanners();
    await _loadCategories();
    await _loadNearbyStores();
    await _loadProducts(page: 1);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await _getFeaturedProducts(page: nextPage, limit: _pageSize);
    result.when(
      ok: (items) {
        final mapped = items.map(_mapProduct).toList();
        final added = _appendProducts(mapped);
        _page = nextPage;
        _hasMore = mapped.length >= _pageSize;
        if (mapped.isEmpty || added == 0) _hasMore = false;
        _applyFilters();
        _updateCache(
          products: List<DashboardProductTile>.from(_products),
          page: _page,
          hasMore: _hasMore,
        );
      },
      err: (message) {
        _error = message;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _query = value;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(int? categoryId, {bool toggle = true}) {
    if (toggle && _selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
    }
    _applyFilters();
    notifyListeners();
  }

  void updateSortOption(ProductSortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  void applyFilterSelection({
    int? categoryId,
    required ProductSortOption sortOption,
    double? minPrice,
    double? maxPrice,
  }) {
    _selectedCategoryId = categoryId;
    _sortOption = sortOption;
    _minPriceFilter = minPrice;
    _maxPriceFilter = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  void clearPriceFilter() {
    _minPriceFilter = null;
    _maxPriceFilter = null;
    _applyFilters();
    notifyListeners();
  }

  Future<void> refreshNearbyStores() async {
    await _loadNearbyStores();
  }

  Future<void> refreshBanners() async {
    await _loadBanners();
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories();
    result.when(
      ok: (items) {
        _categories = items.map(_mapCategory).toList();
        _categoryError = null;
      },
      err: (message) {
        _categoryError = message;
      },
    );
  }

  Future<void> _loadProducts({required int page}) async {
    final result = await _getFeaturedProducts(page: page, limit: _pageSize);
    result.when(
      ok: (items) {
        final mapped = items.map(_mapProduct).toList();
        if (page == 1) {
          _products.clear();
        }
        final added = _appendProducts(mapped);
        _page = page;
        _hasMore = mapped.length >= _pageSize;
        if (mapped.isEmpty || added == 0) _hasMore = false;
        _error = null;
        _updateCache(
          products: List<DashboardProductTile>.from(_products),
          page: _page,
          hasMore: _hasMore,
        );
      },
      err: (message) {
        if (_products.isEmpty) {
          _products
            ..clear()
            ..addAll([]);
          _hasMore = false;
          _applyFilters();
        }
        _error = message;
      },
    );
  }

  DashboardCategoryChip _mapCategory(FatherCategory category) {
    return DashboardCategoryChip(
      id: category.id,
      name: category.name,
      imageUrl: category.imageUrl,
    );
  }

  DashboardProductTile _mapProduct(Product product) {
    String? imageUrl;
    final List<String> imageUrls = [];
    for (final image in product.images) {
      if (image.imageUrl.isNotEmpty) {
        imageUrls.add(image.imageUrl);
      }
      if (image.isPrimary == true && imageUrl == null) {
        imageUrl = image.imageUrl;
      }
    }
    imageUrl ??= imageUrls.isNotEmpty ? imageUrls.first : null;
    final stats = _storeRatings[product.storeId];
    if (stats == null) {
      _fetchStoreRating(product.storeId);
    }
    final rating = stats?.avg ?? 0.0;
    final reviews = stats?.count ?? 0;
    return DashboardProductTile(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      status: product.status,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      categoryId: product.categoryId,
      storeCategoryId: product.storeCategoryId,
      storeId: product.storeId,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviews,
    );
  }

  DashboardNearbyStoreTile _mapNearbyStore(NearbyStore store) {
    return DashboardNearbyStoreTile(
      id: store.id,
      name: store.name,
      address: store.address,
      distanceKm: store.distanceKm,
      imageUrl: store.imageUrl,
    );
  }

  DashboardBannerData _mapBanner(BannerEntity banner) {
    return DashboardBannerData(
      id: banner.id,
      title: banner.title,
      imageUrl: banner.imageUrl,
      description: banner.description,
    );
  }

  Future<void> _loadBanners() async {
    if (_isBannerLoading) return;
    _isBannerLoading = true;
    _bannerError = null;
    notifyListeners();

    final result = await _getBannersByStatus('ACTIVE');
    result.when(
      ok: (items) {
        _banners = items.map(_mapBanner).toList();
        _bannerError = null;
        _updateCache(banners: List<DashboardBannerData>.from(_banners));
      },
      err: (message) {
        if (_banners.isEmpty) {
          _banners = [];
        }
        _bannerError = message;
      },
    );

    _isBannerLoading = false;
    notifyListeners();
  }

  Future<void> _loadNearbyStores() async {
    if (_isNearbyLoading) return;
    _isNearbyLoading = true;
    _nearbyError = null;
    notifyListeners();

    try {
      final location = await _locationProvider.getCurrentPosition();
      final result = await _getNearbyStores(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      result.when(
        ok: (items) {
          _nearbyStores = items.map(_mapNearbyStore).toList();
          _nearbyError = null;
          _updateCache(
            nearbyStores: List<DashboardNearbyStoreTile>.from(_nearbyStores),
          );
        },
        err: (message) {
          if (_nearbyStores.isEmpty) {
            _nearbyStores = [];
          }
          _nearbyError = message;
        },
      );
    } on LocationException catch (error) {
      if (_nearbyStores.isEmpty) {
        _nearbyStores = [];
      }
      _nearbyError = error.message;
    } catch (error) {
      if (_nearbyStores.isEmpty) {
        _nearbyStores = [];
      }
      _nearbyError = error.toString();
    }

    _isNearbyLoading = false;
    notifyListeners();
  }

  Future<void> _fetchStoreRating(int storeId) async {
    if (_storeRatingsLoading.contains(storeId)) return;
    _storeRatingsLoading.add(storeId);
    final result = await _getStoreReviewsByStore(storeId);
    _storeRatingsLoading.remove(storeId);
    result.when(
      ok: (reviews) {
        final count = reviews.length;
        final avg = count == 0
            ? 0.0
            : reviews.fold<double>(0, (sum, r) => sum + r.rating) / count;
        _storeRatings[storeId] = _StoreRatingStats(avg, count);
        _rebuildStoreProducts(storeId);
      },
      err: (_) {},
    );
  }

  void _rebuildStoreProducts(int storeId) {
    final stats = _storeRatings[storeId];
    if (stats == null) return;
    for (var i = 0; i < _products.length; i++) {
      final p = _products[i];
      if (p.storeId != storeId) continue;
      _products[i] = DashboardProductTile(
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
      );
    }
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<DashboardProductTile> iterable = _products;

    if (_selectedCategoryId != null) {
      final selectedId = _selectedCategoryId.toString();
      iterable = iterable.where((product) => product.categoryId == selectedId);
    }

    if (_query.trim().isNotEmpty) {
      final keyword = _query.trim().toLowerCase();
      iterable = iterable.where(
        (product) =>
            product.name.toLowerCase().contains(keyword) ||
            (product.description?.toLowerCase().contains(keyword) ?? false),
      );
    }

    if (_minPriceFilter != null) {
      iterable = iterable.where((p) => (p.discountPrice ?? p.price) >= _minPriceFilter!);
    }
    if (_maxPriceFilter != null) {
      iterable = iterable.where((p) => (p.discountPrice ?? p.price) <= _maxPriceFilter!);
    }

    final temp = iterable.toList();
    switch (_sortOption) {
      case ProductSortOption.priceAsc:
        temp.sort((a, b) => (a.discountPrice ?? a.price).compareTo(b.discountPrice ?? b.price));
        break;
      case ProductSortOption.priceDesc:
        temp.sort((a, b) => (b.discountPrice ?? b.price).compareTo(a.discountPrice ?? a.price));
        break;
      case ProductSortOption.none:
        break;
    }
    _filteredProducts = List.unmodifiable(temp);
  }

  int _appendProducts(List<DashboardProductTile> items) {
    final existing = _products.map((e) => e.id).toSet();
    final newOnes = items.where((p) => existing.add(p.id)).toList();
    _products.addAll(newOnes);
    return newOnes.length;
  }

  void _restoreCache() {
    final cache = _cache;
    if (cache == null) return;
    if (_banners.isEmpty && cache.banners.isNotEmpty) {
      _banners = List<DashboardBannerData>.from(cache.banners);
    }
    if (_products.isEmpty && cache.products.isNotEmpty) {
      _products
        ..clear()
        ..addAll(cache.products);
      _page = cache.page;
      _hasMore = cache.hasMore;
      _applyFilters();
    }
    if (_nearbyStores.isEmpty && cache.nearbyStores.isNotEmpty) {
      _nearbyStores = List<DashboardNearbyStoreTile>.from(cache.nearbyStores);
    }
  }

  void _updateCache({
    List<DashboardBannerData>? banners,
    List<DashboardProductTile>? products,
    List<DashboardNearbyStoreTile>? nearbyStores,
    int? page,
    bool? hasMore,
  }) {
    final current = _cache;
    _cache = _DashboardCache(
      banners: banners ?? current?.banners ?? const [],
      products: products ?? current?.products ?? const [],
      nearbyStores: nearbyStores ?? current?.nearbyStores ?? const [],
      page: page ?? current?.page ?? 1,
      hasMore: hasMore ?? current?.hasMore ?? true,
    );
  }

}

class _StoreRatingStats {
  final double avg;
  final int count;
  const _StoreRatingStats(this.avg, this.count);
}

class _DashboardCache {
  final List<DashboardBannerData> banners;
  final List<DashboardProductTile> products;
  final List<DashboardNearbyStoreTile> nearbyStores;
  final int page;
  final bool hasMore;

  const _DashboardCache({
    required this.banners,
    required this.products,
    required this.nearbyStores,
    required this.page,
    required this.hasMore,
  });
}
