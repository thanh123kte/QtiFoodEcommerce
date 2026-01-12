import 'package:dio/dio.dart';

import '../../domain/entities/store_review_input.dart';
import '../../domain/entities/store_review.dart';
import '../../domain/repositories/store_review_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/store_review_remote.dart';
import '../models/store_review_model.dart';

class StoreReviewRepositoryImpl implements StoreReviewRepository {
  final StoreReviewRemote remote;

  StoreReviewRepositoryImpl(this.remote);

  @override
  Future<Result<int>> createReview(StoreReviewInput input) async {
    try {
      final id = await remote.createReview(input.toJson());
      if (id == 0) return const Err('Tao danh gia that bai');
      return Ok(id);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> uploadImages({required int reviewId, required List<MultipartFile> files}) async {
    try {
      if (files.isEmpty) return const Ok(null);
      await remote.uploadImages(reviewId: reviewId, files: files);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteImage({required int reviewId, required int imageId}) async {
    try {
      await remote.deleteImage(reviewId: reviewId, imageId: imageId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> replyToReview({required int reviewId, required String reply}) async {
    try {
      await remote.reply(reviewId: reviewId, reply: reply);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<StoreReview>>> getReviewsByStore(int storeId) async {
    try {
      final jsonList = await remote.getReviewsByStore(storeId);
      final models = jsonList.map((e) => StoreReviewModel.fromJson(e)).toList();
      return Ok(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
