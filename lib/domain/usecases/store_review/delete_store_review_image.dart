import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../repositories/store_review_repository.dart';

class DeleteStoreReviewImage {
  final StoreReviewRepository _repository;
  DeleteStoreReviewImage(this._repository);

  Future<Result<void>> call({required int reviewId, required int imageId}) {
    return _repository.deleteImage(reviewId: reviewId, imageId: imageId);
  }
}