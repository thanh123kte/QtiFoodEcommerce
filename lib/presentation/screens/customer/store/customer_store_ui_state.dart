import 'package:datn_foodecommerce_flutter_app/domain/entities/store.dart';

import '../dashboard/customer_dashboard_view_model.dart' show DashboardProductTile;

class StoreCategoryChipData {
  final int id;
  final String name;

  const StoreCategoryChipData({
    required this.id,
    required this.name,
  });
}

class StoreReviewViewData {
  final String initials;
  final String author;
  final String comment;
  final double rating;
  final String dateLabel;
  final String? reply;
  final String? replyDateLabel;
  final String? avatarUrl;
  final List<String> imageUrls;

  const StoreReviewViewData({
    required this.initials,
    required this.author,
    required this.comment,
    required this.rating,
    required this.dateLabel,
    this.reply,
    this.replyDateLabel,
    this.avatarUrl,
    this.imageUrls = const [],
  });
}

enum StoreStatus { idle, loading, success, error }

class CustomerStoreUiState {
  static const _noChange = Object();

  final StoreStatus status;
  final bool isFavoriteProcessing;
  final bool isFavorited;
  final int? storeId;
  final String? customerId;
  final Store? store;
  final String? errorMessage;
  final String? categoryError;
  final String? productError;
  final String query;
  final int? selectedCategoryId;
  final List<StoreCategoryChipData> categories;
  final List<DashboardProductTile> products;
  final List<DashboardProductTile> visibleProducts;
  final List<StoreReviewViewData> reviews;

  bool get isLoading => status == StoreStatus.loading;
  bool get hasError => status == StoreStatus.error && errorMessage != null;

  const CustomerStoreUiState({
    required this.status,
    required this.isFavoriteProcessing,
    required this.isFavorited,
    required this.storeId,
    required this.customerId,
    required this.store,
    required this.errorMessage,
    required this.categoryError,
    required this.productError,
    required this.query,
    required this.selectedCategoryId,
    required this.categories,
    required this.products,
    required this.visibleProducts,
    required this.reviews,
  });

  factory CustomerStoreUiState.initial() {
    return const CustomerStoreUiState(
      status: StoreStatus.idle,
      isFavoriteProcessing: false,
      isFavorited: false,
      storeId: null,
      customerId: null,
      store: null,
      errorMessage: null,
      categoryError: null,
      productError: null,
      query: '',
      selectedCategoryId: null,
      categories: <StoreCategoryChipData>[],
      products: <DashboardProductTile>[],
      visibleProducts: <DashboardProductTile>[],
      reviews: <StoreReviewViewData>[],
    );
  }

  CustomerStoreUiState copyWith({
    StoreStatus? status,
    bool? isFavoriteProcessing,
    bool? isFavorited,
    Object? storeId = _noChange,
    Object? customerId = _noChange,
    Object? store = _noChange,
    Object? errorMessage = _noChange,
    Object? categoryError = _noChange,
    Object? productError = _noChange,
    String? query,
    Object? selectedCategoryId = _noChange,
    List<StoreCategoryChipData>? categories,
    List<DashboardProductTile>? products,
    List<DashboardProductTile>? visibleProducts,
    List<StoreReviewViewData>? reviews,
  }) {
    return CustomerStoreUiState(
      status: status ?? this.status,
      isFavoriteProcessing: isFavoriteProcessing ?? this.isFavoriteProcessing,
      isFavorited: isFavorited ?? this.isFavorited,
      storeId: storeId == _noChange ? this.storeId : storeId as int?,
      customerId: customerId == _noChange ? this.customerId : customerId as String?,
      store: store == _noChange ? this.store : store as Store?,
      errorMessage: errorMessage == _noChange ? this.errorMessage : errorMessage as String?,
      categoryError: categoryError == _noChange ? this.categoryError : categoryError as String?,
      productError: productError == _noChange ? this.productError : productError as String?,
      query: query ?? this.query,
      selectedCategoryId:
          selectedCategoryId == _noChange ? this.selectedCategoryId : selectedCategoryId as int?,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      reviews: reviews ?? this.reviews,
    );
  }
}
