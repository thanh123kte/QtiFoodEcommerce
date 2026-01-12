import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/create_store_category_input.dart';
import '../../../../domain/entities/store_category.dart';
import '../../../../domain/usecases/category/get_categories.dart';
import '../../../../domain/usecases/store_category/create_store_category.dart';
import '../../../../domain/usecases/store_category/delete_store_category.dart';
import '../../../../domain/usecases/store_category/get_store_categories.dart';
import '../../../../domain/usecases/store_category/update_store_category.dart';
import '../../../../utils/result.dart';

class StoreCategoryViewData {
  final int id;
  final int storeId;
  final String name;
  final String? description;
  final int? parentCategoryId;

  const StoreCategoryViewData({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    this.parentCategoryId,
  });

  StoreCategoryViewData copyWith({
    int? id,
    int? storeId,
    String? name,
    String? description,
    int? parentCategoryId,
  }) {
    return StoreCategoryViewData(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    );
  }

  factory StoreCategoryViewData.fromEntity(StoreCategory category) {
    return StoreCategoryViewData(
      id: category.id,
      storeId: category.storeId,
      name: category.name,
      description: category.description,
      parentCategoryId: category.parentCategoryId,
    );
  }
}

class StoreCategoriesViewModel extends ChangeNotifier {
  final GetStoreCategories _getCategories;
  final CreateStoreCategory _createCategory;
  final UpdateStoreCategory _updateCategory;
  final DeleteStoreCategory _deleteCategory;
  final GetCategories _getParentCategories;

  StoreCategoriesViewModel(
    this._getCategories,
    this._createCategory,
    this._updateCategory,
    this._deleteCategory,
    this._getParentCategories,
  );

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  int? _storeId;
  String _query = '';

  List<StoreCategoryViewData> _categories = const [];
  List<StoreCategoryViewData> _filtered = const [];
  List<FatherCategory> _parentCategories = const [];
  Future<void>? _parentCategoriesFuture;
  bool _isParentCategoriesLoading = false;
  String? _parentCategoriesError;

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<StoreCategoryViewData> get categories => _filtered;
  bool get hasData => _filtered.isNotEmpty;
  List<FatherCategory> get parentCategories => List.unmodifiable(_parentCategories);
  bool get parentCategoriesLoading => _isParentCategoriesLoading;
  String? get parentCategoriesError => _parentCategoriesError;

  Future<void> load({required int storeId, bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    _storeId = storeId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getCategories(storeId);
    result.when(
      ok: (items) {
        _categories = items.map(StoreCategoryViewData.fromEntity).toList();
        _applyFilter();
        _error = null;
      },
      err: (message) {
        _error = message;
        _categories = const [];
        _filtered = const [];
      },
    );
    _isLoading = false;
    notifyListeners();

    await ensureParentCategoriesLoaded();
  }

  Future<void> refresh() async {
    final id = _storeId;
    if (id == null) return;
    await load(storeId: id, refresh: true);
    await _fetchParentCategories(force: true);
  }

  void search(String query) {
    _query = query;
    _applyFilter();
    notifyListeners();
  }

  Future<void> ensureParentCategoriesLoaded() async {
    if (_parentCategories.isNotEmpty || _isParentCategoriesLoading) return;
    await _fetchParentCategories();
  }

  Future<void> _fetchParentCategories({bool force = false}) async {
    if (!force) {
      if (_parentCategories.isNotEmpty) return;
      final pending = _parentCategoriesFuture;
      if (pending != null) {
        await pending;
        return;
      }
    } else if (_parentCategoriesFuture != null) {
      await _parentCategoriesFuture;
    }

    Future<void> load() async {
      _isParentCategoriesLoading = true;
      _parentCategoriesError = null;
      notifyListeners();

      final result = await _getParentCategories();
      result.when(
        ok: (items) {
          _parentCategories = List.unmodifiable(items);
          _parentCategoriesError = null;
        },
        err: (message) {
          _parentCategoriesError = message;
          _parentCategories = const [];
        },
      );
      _isParentCategoriesLoading = false;
      notifyListeners();
    }

    final future = load();
    _parentCategoriesFuture = future;
    await future;
    if (identical(_parentCategoriesFuture, future)) {
      _parentCategoriesFuture = null;
    }
  }

  String? parentCategoryName(int? id) {
    if (id == null || id == 0) return null;
    for (final category in _parentCategories) {
      if (category.id == id) {
        return category.name;
      }
    }
    return null;
  }

  Future<Result<StoreCategoryViewData>> addCategory({
    required String name,
    String? description,
    required int parentCategoryId,
  }) async {
    final storeId = _storeId;
    if (storeId == null || storeId == 0) {
      return const Err('Không tìm thấy cửa hàng để tạo danh mục.');
    }

    _isProcessing = true;
    notifyListeners();

    final input = CreateStoreCategoryInput(
      storeId: storeId,
      name: name,
      description: description,
      parentCategoryId: parentCategoryId,
    );
    final result = await _createCategory(input);

    return result.when(
      ok: (category) {
        final viewData = StoreCategoryViewData.fromEntity(category);
        _categories = [..._categories, viewData];
        _applyFilter();
        _error = null;
        _isProcessing = false;
        notifyListeners();
        return Ok(viewData);
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  Future<Result<StoreCategoryViewData>> updateCategory({
    required int id,
    required String name,
    String? description,
    required int parentCategoryId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    final input = UpdateStoreCategoryInput(
      name: name,
      description: description,
      parentCategoryId: parentCategoryId,
    );
    final result = await _updateCategory(id, input);

    return result.when(
      ok: (category) {
        final updated = StoreCategoryViewData.fromEntity(category);
        _categories = _categories.map((item) => item.id == id ? updated : item).toList();
        _applyFilter();
        _error = null;
        _isProcessing = false;
        notifyListeners();
        return Ok(updated);
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  Future<Result<void>> deleteCategory(int id) async {
    _isProcessing = true;
    notifyListeners();

    final result = await _deleteCategory(id);
    return result.when(
      ok: (_) {
        _categories = _categories.where((item) => item.id != id).toList();
        _applyFilter();
        _error = null;
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

  void _applyFilter() {
    if (_query.trim().isEmpty) {
      _filtered = List.unmodifiable(_categories);
      return;
    }

    final lower = _query.trim().toLowerCase();
    _filtered = _categories
        .where(
          (item) =>
              item.name.toLowerCase().contains(lower) ||
              (item.description?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
  }
}
