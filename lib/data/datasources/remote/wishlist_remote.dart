import 'package:dio/dio.dart';

class WishlistRemote {
  final Dio dio;

  WishlistRemote(this.dio);

  Future<void> addStoreToWishlist({
    required String customerId,
    required int storeId,
  }) async {
    final storeIdValue = storeId;
    await dio.post(
      '/api/wishlist/$customerId',
      data: {
        'storeId': storeIdValue,
      },
    );
  }

  Future<void> removeStoreFromWishlist({
    required String customerId,
    required int storeId,
  }) async {
    final storeIdValue = storeId;
    await dio.delete(
      '/api/wishlist/$customerId/store/$storeIdValue',
    );
  }

  Future<bool> isStoreInWishlist({
    required String customerId,
    required int storeId,
  }) async {
    final response = await dio.get('/api/wishlist/$customerId/check/$storeId');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final value = data['inWishlist'] ?? data['in_wishlist'];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getWishlist({
    required String customerId,
  }) async {
    final response = await dio.get('/api/wishlist/$customerId');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
