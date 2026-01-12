import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/store_review_input.dart';
import '../../repositories/store_review_repository.dart';


class CreateStoreReview {
  final StoreReviewRepository _repository;
  CreateStoreReview(this._repository);

  Future<Result<int>> call(StoreReviewInput input) {
    return _repository.createReview(input);
  }
}