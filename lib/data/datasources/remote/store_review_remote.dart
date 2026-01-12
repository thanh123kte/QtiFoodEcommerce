import 'package:dio/dio.dart';

class StoreReviewRemote {
  final Dio dio;
  StoreReviewRemote(this.dio);

  Future<int> createReview(Map<String, dynamic> payload) async {
    final response = await dio.post('/api/store-reviews', data: payload);
    final data = response.data;
    if (data is Map && data['id'] != null) {
      return (data['id'] as num).toInt();
    }
    if (data is Map && data['data'] is Map && (data['data'] as Map)['id'] != null) {
      return ((data['data'] as Map)['id'] as num).toInt();
    }
    return 0;
  }

  Future<void> uploadImages({required int reviewId, required List<MultipartFile> files}) async {
    final formData = FormData.fromMap({
      'images': files,
    });
    await dio.post('/api/store-reviews/$reviewId/images', data: formData);
  }

  Future<void> deleteImage({required int reviewId, required int imageId}) async {
    await dio.delete('/api/store-reviews/$reviewId/images/$imageId');
  }

  Future<void> reply({required int reviewId, required String reply}) async {
    await dio.post('/api/store-reviews/$reviewId/reply', data: {
      'reply': reply,
    });
  }

  Future<List<Map<String, dynamic>>> getReviewsByStore(int storeId) async {
    final response = await dio.get('/api/store-reviews/store/$storeId');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
