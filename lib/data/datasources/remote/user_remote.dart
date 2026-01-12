import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class UserRemote {
  final Dio dio;
  UserRemote(this.dio);

  // POST /api/users
  Future<void> postUser(Map<String, dynamic> body) async {
    await dio.post('/api/users', data: body);
  }

  // GET /api/user/{id}
  Future<Map<String, dynamic>> getUserById(String id) async {
    final res = await dio.get('/api/users/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<void> updateUser(String id, Map<String, dynamic> body) async {
    await dio.put('/api/users/$id', data: body);
  }

  Future<String> uploadAvatar(String id, String filePath) async {
    final fileName = path.basename(filePath);
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final res = await dio.post(
      '/api/users/$id/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = res.data;
    String? candidate;
    if (data is String) candidate = data;
    if (data is Map<String, dynamic>) {
      final map = data;
      if (map['avatarUrl'] is String && (map['avatarUrl'] as String).isNotEmpty) {
        candidate = map['avatarUrl'] as String;
      }
      if (candidate == null && map['url'] is String && (map['url'] as String).isNotEmpty) {
        candidate = map['url'] as String;
      }
      if (candidate == null && map['data'] is Map && (map['data'] as Map)['avatarUrl'] is String) {
        candidate = (map['data'] as Map)['avatarUrl'] as String;
      }
    }

    if (candidate != null && candidate.isNotEmpty) {
      return _resolveUrl(candidate);
    }

    throw Exception('Khong doc duoc du lieu avatar tu server');
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    final base = dio.options.baseUrl;
    if (url.startsWith('/')) {
      return base.endsWith('/') ? '${base.substring(0, base.length - 1)}$url' : '$base$url';
    }
    return base.endsWith('/') ? '$base$url' : '$base/$url';
  }
}
