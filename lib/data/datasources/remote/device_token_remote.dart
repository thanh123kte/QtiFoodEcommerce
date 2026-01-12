import 'package:dio/dio.dart';

class DeviceTokenRemote {
  final Dio dio;

  DeviceTokenRemote(this.dio);

  Future<void> registerToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    await dio.post(
      '/api/device-tokens',
      data: {
        'token': token,
        'platform': platform,
      },
      options: Options(
        headers: {
          'X-User-ID': userId,
        },
      ),
    );
  }

  Future<List<String>> getTokens(String userId) async {
    final res = await dio.get(
      '/api/device-tokens',
      options: Options(headers: {'X-User-ID': userId}),
    );
    final data = res.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  Future<void> deleteToken({
    required String userId,
    required String token,
  }) async {
    await dio.delete(
      '/api/device-tokens',
      queryParameters: {'token': token},
      options: Options(headers: {'X-User-ID': userId}),
    );
  }
}
