import 'package:dio/dio.dart';

class VoucherRemote {
  final Dio dio;

  VoucherRemote(this.dio);

  Future<List<Map<String, dynamic>>> getByStore(int storeId) async {
    final normalizedId = storeId;
    final response = await dio.get('/api/vouchers/store/$normalizedId/isnot_deleted');
    return _parseList(response);
  }

  Future<List<Map<String, dynamic>>> getAdminVouchers() async {
    final response = await dio.get(
      '/api/vouchers/admin/isnot_deleted',
    );
    return _parseList(response);
  }

  Future<Map<String, dynamic>> getVoucher(int id) async {
    final response = await dio.get('/api/vouchers/$id');
    return _parseObject(response);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await dio.post('/api/vouchers', data: payload);
    return _parseObject(response);
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> payload) async {
    final response = await dio.put('/api/vouchers/$id', data: payload);
    return _parseObject(response);
  }

  Future<void> updateUsage(int id, {int? usageCount, int? usageLimit}) async {
    await dio.post('/api/vouchers/$id/increment-usage');
  }

  Future<void> delete(int id) async {
    await dio.put('/api/vouchers/$id/soft-delete');
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
      if (data is Map) {
        return [Map<String, dynamic>.from(data)];
      }
    }

    return const [];
  }

  Map<String, dynamic> _parseObject(Response<dynamic> response) {
    final body = response.data;
    if (body == null) return <String, dynamic>{};

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
