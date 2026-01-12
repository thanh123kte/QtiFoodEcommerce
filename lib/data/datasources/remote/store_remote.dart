import 'package:dio/dio.dart';

class StoreRemote {
  final Dio dio;

  StoreRemote(this.dio);

  Future<Map<String, dynamic>?> createStore(Map<String, dynamic> payload) async {
    final response = await dio.post('/api/stores', data: payload);
    return _parseStoreResponse(response);
  }

  Future<Map<String, dynamic>?> getStoreByOwner(String ownerId) async {
    if (ownerId.isEmpty) return null;
    final response = await dio.get('/api/stores/owner/$ownerId');
    return _parseStoreResponse(response);
  }

  Future<Map<String, dynamic>?> getStore(int storeId) async {
    final response = await dio.get('/api/stores/$storeId');
    return _parseStoreResponse(response);
  }

  Future<void> incrementView(int storeId) async {
    await dio.post('/api/stores/$storeId/view');
  }

  Future<Map<String, dynamic>?> uploadStoreImage({
    required int storeId,
    required MultipartFile file,
  }) async {
    final formData = FormData();
    formData.files.add(MapEntry('image', file));
    final response = await dio.post('/api/stores/$storeId/image', data: formData);
    return _parseStoreResponse(response);
  }

  Future<Map<String, dynamic>?> updateStore(
    int storeId,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.put('/api/stores/$storeId', data: payload);
    return _parseStoreResponse(response);
  }

  Future<List<Map<String, dynamic>>> getNearbyStores({
    required double latitude,
    required double longitude,
  }) async {
    final response = await dio.get(
      '/api/stores/nearby',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
      },
    );
    return _parseStoreListResponse(response);
  }

  Map<String, dynamic>? _parseStoreResponse(Response<dynamic> response) {
    final body = response.data;

    if (body == null) return null;

    // Case API trả thẳng list: [ { ...store... } ]
    if (body is List) {
      if (body.isEmpty) return null;
      final first = body.first;
      if (first is Map<String, dynamic>) {
        return Map<String, dynamic>.from(first);
      }
      return null;
    }

    // Case API trả map, có thể bọc "data"
    if (body is Map<String, dynamic>) {
      final payload = body.containsKey('data') ? body['data'] : body;

      if (payload == null) return null;

      if (payload is Map<String, dynamic>) {
        return Map<String, dynamic>.from(payload);
      }

      if (payload is List) {
        if (payload.isEmpty) return null;
        final first = payload.first;
        if (first is Map<String, dynamic>) {
          return Map<String, dynamic>.from(first);
        }
        return null;
      }
    }

    // Các định dạng khác coi như không hợp lệ
    return null;
  }

  List<Map<String, dynamic>> _parseStoreListResponse(Response<dynamic> response) {
    final body = response.data;
    if (body == null) return const [];

    if (body is List) {
      return body
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (body is Map<String, dynamic>) {
      final payload = body.containsKey('data') ? body['data'] : body;
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

}
