import 'package:datn_foodecommerce_flutter_app/domain/usecases/product/get_product_images.dart';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/create_product_input.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/product_image_file.dart';
import '../../../../domain/entities/store.dart';
import '../../../../domain/entities/store_category.dart';
import '../../../../domain/entities/update_product_input.dart';
import '../../../../domain/usecases/category/get_categories.dart';
import '../../../../domain/usecases/product/create_product.dart';
import '../../../../domain/usecases/product/delete_product.dart';
import '../../../../domain/usecases/product/get_store_products.dart';
import '../../../../domain/usecases/product/update_product.dart';
import '../../../../domain/usecases/product/upload_product_images.dart';
import '../../../../domain/usecases/store/get_store_by_owner.dart';
import '../../../../domain/usecases/store_category/get_store_categories.dart';
import '../../../../utils/result.dart';

class ProductStatus {
  static const available = 'AVAILABLE';
  static const inactive = 'UNAVAILABLE';

  static const values = [available, inactive];

  static String label(String value) {
    switch (value) {
      case inactive:
        return 'Tạm ngưng';
      case available:
      default:
        return 'Sẵn sàng';
    }
  }
}

class ProductImageViewData {
  final String id;
  final String url;
  final bool? isPrimary;

  const ProductImageViewData({
    required this.id,
    required this.url,
    this.isPrimary,
  });
}

class ProductViewData {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String status;
  final String? adminStatus;
  final String? categoryId;
  final String? categoryName;
  final String? storeCategoryId;
  final String? storeCategoryName;
  final List<ProductImageViewData> images;

  const ProductViewData({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.status,
    this.adminStatus,
    this.categoryId,
    this.categoryName,
    this.storeCategoryId,
    this.storeCategoryName,
    this.images = const [],
  });

  ProductViewData copyWith({
    String? name,
    String? description,
    double? price,
    String? status,
    String? adminStatus,
    String? categoryId,
    String? categoryName,
    String? storeCategoryId,
    String? storeCategoryName,
    List<ProductImageViewData>? images,
  }) {
    return ProductViewData(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      adminStatus: adminStatus ?? this.adminStatus,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      storeCategoryId: storeCategoryId ?? this.storeCategoryId,
      storeCategoryName: storeCategoryName ?? this.storeCategoryName,
      images: images ?? this.images,
    );
  }
}

class ProductFormInput {
  final String name;
  final String? description;
  final double price;
  final String status;
  final String? categoryId;
  final String? storeCategoryId;

  const ProductFormInput({
    required this.name,
    this.description,
    required this.price,
    required this.status,
    this.categoryId,
    this.storeCategoryId,
  });
}

class SellerProductsViewModel extends ChangeNotifier {
  final GetStoreByOwner _getStoreByOwner;
  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final UploadProductImages _uploadProductImages;
  final GetProductImages _getProductImages;
  final GetCategories _getCategories;
  final GetStoreCategories _getStoreCategories;

  SellerProductsViewModel(
    this._getStoreByOwner,
    this._getProducts,
    this._createProduct,
    this._updateProduct,
    this._deleteProduct,
    this._uploadProductImages,
    this._getProductImages,
    this._getCategories,
    this._getStoreCategories,
  );

  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isCategoryLoading = false;
  bool _hasStore = false;
  bool _isRefreshingImages = false;
  String? _error;
  int? _storeId;
  String? _storeName;
  String? _categoryError;
  String _query = '';

  List<Product> _productEntities = const [];
  List<ProductViewData> _products = const [];
  List<ProductViewData> _filtered = const [];
  List<FatherCategory> _categories = const [];
  List<StoreCategory> _storeCategories = const [];

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  bool get isCategoryLoading => _isCategoryLoading;
  bool get isRefreshingImages => _isRefreshingImages;
  bool get hasStore => _hasStore;
  bool get hasData => _filtered.isNotEmpty;
  String? get error => _error;
  String? get storeName => _storeName;
  String? get categoryError => _categoryError;
  List<ProductViewData> get products => List.unmodifiable(_filtered);
  List<FatherCategory> get categoryOptions => List.unmodifiable(_categories);
  List<StoreCategory> get storeCategoryOptions => List.unmodifiable(_storeCategories);

  Future<void> load({required String ownerId, bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final storeResult = await _getStoreByOwner(ownerId);
    Store? store;
    storeResult.when(
      ok: (value) => store = value,
      err: (message) => _error = message,
    );

    if (store == null) {
      _hasStore = false;
      _isLoading = false;
      _productEntities = const [];
      _composeViewData();
      notifyListeners();
      return;
    }

    _hasStore = true;
    _storeId = store!.id;
    _storeName = store!.name;

    await Future.wait([
      _fetchProducts(storeId: store!.id, refreshImages: true),
      _loadCategoryOptions(storeId: store!.id),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final storeId = _storeId;
    if (storeId == null) return;
    await _fetchProducts(storeId: storeId, refreshImages: true);
    await _loadCategoryOptions(storeId: storeId, force: true);
    notifyListeners();
  }

  void search(String keyword) {
    _query = keyword;
    _applyFilter();
    notifyListeners();
  }

  Future<Result<ProductViewData>> addProduct({
    required ProductFormInput form,
    required List<ProductImageFile> images,
  }) async {
    final storeId = _storeId;
    if (storeId == null) {
      return const Err('Khong tim thay cua hang.');
    }

    _isProcessing = true;
    notifyListeners();

    final input = CreateProductInput(
      storeId: storeId,
      categoryId: _deriveCategoryId(form.storeCategoryId, form.categoryId),
      storeCategoryId: form.storeCategoryId,
      name: form.name,
      description: form.description,
      price: form.price,
      discountPrice: null,
      status: form.status,
    );

    final result = await _createProduct(input);
    return await result.when(
      ok: (product) async {
        final uploadResult = await _maybeUploadImages(product.id, images);
        return uploadResult.when(
          ok: (uploadedImages) {
            final entity = product.copyWith(images: uploadedImages.isEmpty ? product.images : uploadedImages);
            _productEntities = [..._productEntities, entity];
            _composeViewData();
            _isProcessing = false;
            notifyListeners();
            return Ok(_toViewData(entity));
          },
          err: (message) {
            _isProcessing = false;
            _error = message;
            notifyListeners();
            return Err(message);
          },
        );
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  Future<Result<ProductViewData>> updateProduct({
    required String productId,
    required ProductFormInput form,
    required List<ProductImageFile> newImages,
    bool replaceImages = false,
  }) async {
    _isProcessing = true;
    notifyListeners();

    final input = UpdateProductInput(
      categoryId: _deriveCategoryId(form.storeCategoryId, form.categoryId),
      storeCategoryId: form.storeCategoryId,
      name: form.name,
      description: form.description,
      price: form.price,
      discountPrice: null,
      status: form.status,
    );

    final result = await _updateProduct(productId, input);
    return await result.when(
      ok: (product) async {
        final existing = _productEntities.firstWhere(
          (item) => item.id == productId,
          orElse: () => product,
        );

        if (newImages.isEmpty) {
          final merged = product.images.isNotEmpty ? product : product.copyWith(images: existing.images);
          _productEntities = _productEntities.map((item) => item.id == productId ? merged : item).toList();
          _composeViewData();
          _isProcessing = false;
          notifyListeners();
          return Ok(_toViewData(merged));
        }

        final uploadResult = await _maybeUploadImages(productId, newImages, replace: replaceImages);
        return uploadResult.when(
          ok: (uploaded) {
            final fallbackImages =
                uploaded.isNotEmpty ? uploaded : (product.images.isNotEmpty ? product.images : existing.images);
            final entity = product.copyWith(images: fallbackImages);
            _productEntities = _productEntities.map((item) => item.id == productId ? entity : item).toList();
            _composeViewData();
            _isProcessing = false;
            notifyListeners();
            return Ok(_toViewData(entity));
          },
          err: (message) {
            _isProcessing = false;
            _error = message;
            notifyListeners();
            return Err(message);
          },
        );
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  Future<Result<void>> deleteProduct(String productId) async {
    _isProcessing = true;
    notifyListeners();
    final result = await _deleteProduct(productId);
    return result.when(
      ok: (_) {
        _productEntities = _productEntities.where((product) => product.id != productId).toList();
        _composeViewData();
        _isProcessing = false;
        notifyListeners();
        return const Ok(null);
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  ProductViewData? productById(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  Future<void> _fetchProducts({required int storeId, bool refreshImages = false}) async {
    final result = await _getProducts(storeId: storeId, keyword: _query.isEmpty ? null : _query);
    result.when(
      ok: (items) {
        _productEntities = items;
        developer.log(
          'Fetched ${items.length} products for store $storeId',
          name: 'SellerProductsViewModel',
        );
        _error = null;
      },
      err: (message) {
        _productEntities = const [];
        _error = message;
      },
    );
    _composeViewData();
    if (refreshImages) {
      await _reloadProductImages();
    }
  }

  Future<void> _loadCategoryOptions({required int storeId, bool force = false}) async {
    if (_isCategoryLoading && !force) return;
    if (!force && _categories.isNotEmpty && _storeCategories.isNotEmpty) return;

    _isCategoryLoading = true;
    notifyListeners();

    String? message;
    final categoryResult = await _getCategories();
    categoryResult.when(
      ok: (items) => _categories = items,
      err: (err) => message = err,
    );

    final storeCategoryResult = await _getStoreCategories(storeId);
    storeCategoryResult.when(
      ok: (items) => _storeCategories = items,
      err: (err) => message ??= err,
    );

    _categoryError = message;
    _isCategoryLoading = false;
    _composeViewData();
  }

  Future<Result<List<ProductImage>>> _maybeUploadImages(
    String productId,
    List<ProductImageFile> images, {
    bool replace = false,
  }) async {
    if (images.isEmpty) {
      return const Ok([]);
    }
    developer.log(
      'Uploading ${images.length} images for product $productId replace=$replace',
      name: 'SellerProductsViewModel',
    );
    return _uploadProductImages(productId, images, replace: replace);
  }

  Future<void> _reloadProductImages() async {
    if (_productEntities.isEmpty) return;
    _isRefreshingImages = true;
    notifyListeners();

    final futures = _productEntities.map(
      (product) async {
        final result = await _getProductImages(product.id);
        return result.when<List<ProductImage>>(
          ok: (images) => images,
          err: (_) => const [],
        );
      },
    );

    final updatedImages = await Future.wait(futures);
    final List<Product> updatedProducts = [];
    for (var i = 0; i < _productEntities.length; i++) {
      final product = _productEntities[i];
      final images = updatedImages[i];
      updatedProducts.add(images.isEmpty ? product : product.copyWith(images: images));
    }
    _productEntities = updatedProducts;
    _composeViewData();

    _isRefreshingImages = false;
    notifyListeners();
  }

  void _composeViewData() {
    final categoryMap = {for (final category in _categories) category.id: category.name};
    final storeCategoryMap = {for (final category in _storeCategories) category.id: category.name};
    developer.log(
      'Composing view data for ${_productEntities.length} products. Image counts: ${_productEntities.map((e) => '${e.id}:${e.images.length}').join(', ')}',
      name: 'SellerProductsViewModel',
    );
    _products = _productEntities
        .map(
          (product) => ProductViewData(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            status: product.status,
            adminStatus: product.adminStatus,
            categoryId: product.categoryId,
            categoryName: product.categoryId == null ? null : categoryMap[product.categoryId],
            storeCategoryId: product.storeCategoryId,
            storeCategoryName: product.storeCategoryId == null ? null : storeCategoryMap[product.storeCategoryId],
            images: product.images
                .map(
                  (image) => ProductImageViewData(
                    id: image.id,
                    url: image.imageUrl,
                    isPrimary: image.isPrimary,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList();
    _applyFilter();
  }

  void _applyFilter() {
    if (_query.trim().isEmpty) {
      _filtered = List.unmodifiable(_products);
      return;
    }

    final lower = _query.trim().toLowerCase();
    _filtered = _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(lower) ||
              (product.description?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
  }

  ProductViewData _toViewData(Product product) {
    final categoryMap = {for (final category in _categories) category.id: category.name};
    final storeCategoryMap = {for (final category in _storeCategories) category.id: category.name};
    return ProductViewData(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      status: product.status,
      adminStatus: product.adminStatus,
      categoryId: product.categoryId,
      categoryName: product.categoryId == null ? null : categoryMap[product.categoryId],
      storeCategoryId: product.storeCategoryId,
      storeCategoryName: product.storeCategoryId == null ? null : storeCategoryMap[product.storeCategoryId],
      images: product.images
          .map(
            (image) => ProductImageViewData(
              id: image.id,
              url: image.imageUrl,
              isPrimary: image.isPrimary,
            ),
          )
          .toList(),
    );
  }

  String? _deriveCategoryId(String? storeCategoryId, String? fallback) {
    final parsedStoreCategoryId = storeCategoryId != null ? int.tryParse(storeCategoryId) : null;
    if (parsedStoreCategoryId != null) {
      for (final category in _storeCategories) {
        if (category.id == parsedStoreCategoryId) {
          final parent = category.parentCategoryId;
          if (parent != null && parent > 0) {
            return parent.toString();
          }
        }
      }
    }
    return fallback;
  }
}
