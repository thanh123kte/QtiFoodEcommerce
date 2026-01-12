import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../../../config/server_config.dart';
import '../../../../domain/entities/store_review.dart';
import '../../../../domain/usecases/store/get_store_by_owner.dart';
import '../../../../domain/usecases/store_review/get_store_reviews_by_store.dart';
import '../../../../domain/usecases/store_review/reply_store_review.dart';
import 'seller_profile_overview_state.dart';

class SellerProfileOverviewViewModel extends ChangeNotifier {
  final GetStoreByOwner _getStoreByOwner;
  final GetStoreReviewsByStore _getStoreReviewsByStore;
  final ReplyStoreReview _replyStoreReview;

  SellerProfileOverviewViewModel(
    this._getStoreByOwner,
    this._getStoreReviewsByStore,
    this._replyStoreReview,
  );

  SellerProfileOverviewState _state = const SellerProfileOverviewInitial();
  SellerProfileOverviewState get state => _state;

  SellerProfileViewData? get currentData {
    final s = _state;
    if (s is SellerProfileOverviewLoaded) return s.data;
    return null;
  }

  String? _ownerId;
  bool _isLoading = false;
  bool _isLoadingReviews = false;
  String? _errorMessage;
  final Set<int> _replyingIds = {};

  bool get isLoading => _isLoading;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  Set<int> get replyingReviewIds => Set.unmodifiable(_replyingIds);

  void _emit(SellerProfileOverviewState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadStore({required String ownerId, bool forceRefresh = false}) async {
    if (ownerId.isEmpty) {
      _emit(const SellerProfileOverviewError('Không tìm thấy thông tin cửa hàng'));
      return;
    }
    _ownerId = ownerId;
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    if (!forceRefresh) {
      _emit(const SellerProfileOverviewLoading());
    } else {
      notifyListeners();
    }

    final result = await _getStoreByOwner(ownerId);
    result.when(
      ok: (store) {
        if (store == null) {
          _emit(const SellerProfileOverviewError('Bạn chưa có cửa hàng, vui lòng đăng ký.'));
        } else {
          final viewData = SellerProfileViewData.fromStore(store);
          _emit(SellerProfileOverviewLoaded(viewData));
          _fetchReviews(store.id);
        }
      },
      err: (message) {
        _emit(SellerProfileOverviewError(message));
      },
    );
    _isLoading = false;
  }

  Future<void> retry() async {
    final id = _ownerId;
    if (id == null) return;
    await loadStore(ownerId: id, forceRefresh: true);
  }

  Future<void> _fetchReviews(int storeId) async {
    if (_isLoadingReviews) return;
    _isLoadingReviews = true;
    notifyListeners();

    final result = await _getStoreReviewsByStore(storeId);
    result.when(
      ok: (items) {
        final mapped = items.map(_mapReview).toList();
        final current = _state;
        if (current is SellerProfileOverviewLoaded) {
          _emit(current.copyWith(reviews: mapped));
        }
      },
      err: (_) {
        // keep existing reviews on error
      },
    );

    _isLoadingReviews = false;
    notifyListeners();
  }

  Future<Result<void>> replyToReview({required int reviewId, required String reply}) async {
    final trimmed = reply.trim();
    if (trimmed.isEmpty) {
      return const Err('Vui lòng nhập nội dung .');
    }
    if (_replyingIds.contains(reviewId)) {
      return const Err('Đang gửi phản hồi.');
    }
    _replyingIds.add(reviewId);
    notifyListeners();

    final result = await _replyStoreReview(reviewId: reviewId, reply: trimmed);
    result.when(
      ok: (_) {
        final current = _state;
        if (current is SellerProfileOverviewLoaded) {
          final replyDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
          final updated = current.reviews
              .map(
                (review) => review.id == reviewId
                    ? review.copyWith(reply: trimmed, replyDateLabel: replyDate)
                    : review,
              )
              .toList();
          _emit(current.copyWith(reviews: updated));
        }
      },
      err: (message) {
        _errorMessage = message;
      },
    );

    _replyingIds.remove(reviewId);
    notifyListeners();
    return result;
  }

  SellerStoreReviewViewData _mapReview(StoreReview review) {
    final name = review.customerName.trim();
    final initials = _buildInitials(name.isNotEmpty ? name : 'G');
    final dateLabel = review.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(review.createdAt!.toLocal())
        : '';
    final replyDateLabel = review.repliedAt != null
        ? DateFormat('dd/MM/yyyy').format(review.repliedAt!.toLocal())
        : null;
    final images = review.images.map((e) => _resolveImageUrl(e.imageUrl)).whereType<String>().toList();
    return SellerStoreReviewViewData(
      id: review.id,
      initials: initials,
      author: name.isNotEmpty ? name : 'Nguoi dung',
      comment: review.comment,
      rating: review.rating.toDouble(),
      dateLabel: dateLabel,
      reply: review.reply,
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

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final sanitizedPath = value.startsWith('/') ? value.substring(1) : value;
    if (sanitizedPath.isEmpty) return kServerBaseUrl;
    final base = kServerBaseUrl.endsWith('/') ? kServerBaseUrl.substring(0, kServerBaseUrl.length - 1) : kServerBaseUrl;
    return '$base/$sanitizedPath';
  }
}
