import '../../entities/store_review.dart';
import '../../repositories/store_review_repository.dart';
import '../../../utils/result.dart';

class GetStoreReviewsByStore {
  final StoreReviewRepository _repository;
  GetStoreReviewsByStore(this._repository);

  Future<Result<List<StoreReview>>> call(int storeId) {
    return _repository.getReviewsByStore(storeId);
  }
}
