import 'package:dio/dio.dart';

class StoreCategoryRemote {
  final Dio dio;

  StoreCategoryRemote(this.dio);

  Future<List<Map<String, dynamic>>> getByStore(int storeId) async {
    final response = await dio.get('/api/store-categories/store/$storeId/isnot_deleted');
    return _parseList(response);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await dio.post('/api/store-categories', data: payload);
    return _parseObject(response);
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> payload) async {
    final response = await dio.put('/api/store-categories/$id', data: payload);
    return _parseObject(response);
  }

  Future<void> delete(int id) async {
    await dio.put('/api/store-categories/$id/soft-delete');
  }

  List<Map<String, dynamic>> _parseList(Response<dynamic> response) {
    final body = response.data;
    if (body == null) return const [];

    if (body is List) {
      return body.whereType<Map<String, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (data is Map<String, dynamic>) {
        return [Map<String, dynamic>.from(data)];
      }
    }
    return const [];
  }

  Map<String, dynamic> _parseObject(Response<dynamic> response) {
    final body = response.data;
    if (body == null) {
      return <String, dynamic>{};
    }

    if (body is Map<String, dynamic>) {
      if (body['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
      return Map<String, dynamic>.from(body);
    }

    if (body is List && body.isNotEmpty) {
      final first = body.first;
      if (first is Map<String, dynamic>) {
        return Map<String, dynamic>.from(first);
      }
    }

    return <String, dynamic>{};
  }
}
