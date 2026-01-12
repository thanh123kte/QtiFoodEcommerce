import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../repositories/store_review_repository.dart';

class ReplyStoreReview {
  final StoreReviewRepository _repository;

  ReplyStoreReview(this._repository);

  Future<Result<void>> call({required int reviewId, required String reply}) {
    return _repository.replyToReview(reviewId: reviewId, reply: reply);
  }
}
