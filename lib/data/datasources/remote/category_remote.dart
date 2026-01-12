import 'package:dio/dio.dart';

class CategoryRemote {
  final Dio dio;

  CategoryRemote(this.dio);

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await dio.get('/api/categories');
    final data = response.data;

    List<Map<String, dynamic>> normalizeList(dynamic source) {
      if (source is List) {
        return source
            .whereType<Map>()
            .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return const [];
    }

    if (data is List) {
      return normalizeList(data);
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return normalizeList(data['data']);
      }
      if (data['items'] is List) {
        return normalizeList(data['items']);
      }
    }

    return const [];
  }
}
