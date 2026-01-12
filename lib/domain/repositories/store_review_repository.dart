import '../../utils/result.dart';
import '../entities/store_review_input.dart';
import '../entities/store_review.dart';
import 'package:dio/dio.dart';

abstract class StoreReviewRepository {
  Future<Result<int>> createReview(StoreReviewInput input);
  Future<Result<void>> uploadImages({required int reviewId, required List<MultipartFile> files});
  Future<Result<void>> deleteImage({required int reviewId, required int imageId});
  Future<Result<void>> replyToReview({required int reviewId, required String reply});
  Future<Result<List<StoreReview>>> getReviewsByStore(int storeId);
}
