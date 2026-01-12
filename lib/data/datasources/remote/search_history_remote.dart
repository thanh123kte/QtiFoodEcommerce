import 'package:dio/dio.dart';

class SearchHistoryRemote {
  final Dio dio;

  SearchHistoryRemote(this.dio);

  Future<List<Map<String, dynamic>>> getHistory(String userId, {int limit = 5}) async {
    final response = await dio.get(
      '/api/search-history/user/$userId/top-keywords',
      queryParameters: {'limit': limit},
    );
    return _parseList(response.data);
  }

  Future<void> addHistory(String userId, String keyword) async {
    await dio.post(
      '/api/search-history/user/$userId',
      data: {'keyword': keyword},
    );
  }

  List<Map<String, dynamic>> _parseList(dynamic source) {
    if (source == null) return const [];
    if (source is List) {
      return source.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return {'keyword': e?.toString() ?? '', 'searchedAt': DateTime.now().toIso8601String()};
      }).toList();
    }
    if (source is Map) {
      if (source.containsKey('data')) {
        return _parseList(source['data']);
      }
      return [Map<String, dynamic>.from(source)];
    }
    return const [];
  }
}
