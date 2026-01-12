import 'package:dio/dio.dart';

class BannerRemote {
  final Dio dio;

  BannerRemote(this.dio);

  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    final response = await dio.get('/api/banners/status/$status');
    return _parseList(response);
  }

  List<Map<String, dynamic>> _parseList(Response<dynamic> response) {
    final body = response.data;
    if (body == null) return const [];

    if (body is List) {
      return body.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (data is Map<String, dynamic>) {
        return [Map<String, dynamic>.from(data)];
      }
    }

    return const [];
  }
}
