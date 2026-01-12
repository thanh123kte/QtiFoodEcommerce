import 'package:datn_foodecommerce_flutter_app/utils/result.dart';
import 'package:dio/dio.dart';

import '../../repositories/store_review_repository.dart';

class UploadStoreReviewImages {
  final StoreReviewRepository _repository;
  UploadStoreReviewImages(this._repository);

  Future<Result<void>> call({required int reviewId, required List<MultipartFile> files}) {
    return _repository.uploadImages(reviewId: reviewId, files: files);
  }
}