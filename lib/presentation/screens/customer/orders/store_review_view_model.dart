import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../domain/entities/store_review_input.dart';
import '../../../../domain/usecases/store_review/create_store_review.dart';
import '../../../../domain/usecases/store_review/upload_store_review_images.dart';
import '../../../../utils/result.dart';

class StoreReviewUiState {
  final int rating;
  final String comment;
  final bool anonymous;
  final List<XFile> images;
  final bool isSubmitting;
  final String? error;
  final Set<String> tags;

  const StoreReviewUiState({
    this.rating = 5,
    this.comment = '',
    this.anonymous = false,
    this.images = const [],
    this.isSubmitting = false,
    this.error,
    this.tags = const {},
  });

  StoreReviewUiState copyWith({
    int? rating,
    String? comment,
    bool? anonymous,
    List<XFile>? images,
    bool? isSubmitting,
    Object? error = _noChange,
    Set<String>? tags,
  }) {
    return StoreReviewUiState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      anonymous: anonymous ?? this.anonymous,
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error == _noChange ? this.error : error as String?,
      tags: tags ?? this.tags,
    );
  }

  static const _noChange = Object();
}

class StoreReviewViewModel extends ChangeNotifier {
  final CreateStoreReview _createReview;
  final UploadStoreReviewImages _uploadImages;

  StoreReviewViewModel(
    this._createReview,
    this._uploadImages,
  );

  StoreReviewUiState _state = const StoreReviewUiState();
  StoreReviewUiState get state => _state;

  void setRating(int value) {
    _state = _state.copyWith(rating: value.clamp(1, 5));
    notifyListeners();
  }

  void toggleAnonymous(bool value) {
    _state = _state.copyWith(anonymous: value);
    notifyListeners();
  }

  void setComment(String value) {
    _state = _state.copyWith(comment: value);
    notifyListeners();
  }

  void toggleTag(String tag) {
    final tags = Set<String>.from(_state.tags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    _state = _state.copyWith(tags: tags);
    notifyListeners();
  }

  void addImage(XFile file) {
    if (_state.images.length >= 5) return;
    final updated = List<XFile>.from(_state.images)..add(file);
    _state = _state.copyWith(images: updated);
    notifyListeners();
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _state.images.length) return;
    final updated = List<XFile>.from(_state.images)..removeAt(index);
    _state = _state.copyWith(images: updated);
    notifyListeners();
  }

  Future<Result<void>> submit({
    required int orderId,
    required int storeId,
    required String customerId,
  }) async {
    if (_state.isSubmitting) return const Err('Đang gửi đánh giá');
    _state = _state.copyWith(isSubmitting: true, error: null);
    notifyListeners();

    final finalComment = _buildComment();
    final input = StoreReviewInput(
      orderId: orderId,
      storeId: storeId,
      customerId: customerId,
      rating: _state.rating,
      comment: finalComment,
      anonymous: _state.anonymous,
    );

    final created = await _createReview(input);
    int reviewId = 0;
    created.when(
      ok: (id) => reviewId = id,
      err: (message) {
        _state = _state.copyWith(isSubmitting: false, error: message);
        notifyListeners();
      },
    );

    if (reviewId == 0) {
      return const Err('Không thể tạo đánh giá');
    }

    final images = _state.images;
    if (images.isNotEmpty) {
      final files = <MultipartFile>[];
      for (final img in images) {
        files.add(await MultipartFile.fromFile(img.path, filename: img.name));
      }
      final uploadResult = await _uploadImages(reviewId: reviewId, files: files);
      final handled = uploadResult.when(
        ok: (_) => const Ok(null),
        err: (msg) {
          _state = _state.copyWith(isSubmitting: false, error: msg);
          notifyListeners();
          return Err(msg);
        },
      );
      if (handled is Err) return handled;
    }

    _state = _state.copyWith(isSubmitting: false);
    notifyListeners();
    return const Ok(null);
  }

  String _buildComment() {
    final parts = <String>[];
    if (_state.tags.isNotEmpty) {
      parts.add(_state.tags.join(', '));
    }
    final comment = _state.comment.trim();
    if (comment.isNotEmpty) {
      parts.add(comment);
    }
    return parts.join(' ');
  }

}