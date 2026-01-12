import 'package:dio/dio.dart';

class ProductRemote {
  final Dio dio;

  ProductRemote(this.dio);

  Future<List<Map<String, dynamic>>> getFeaturedProducts() 
  async {
    final response = await dio.get(
      '/api/products/isnot_deleted',
    );
    return _parseList(response.data);
  }

  Future<List<Map<String, dynamic>>> getProductsByStore({
    required int storeId,
    String? keyword,
  }) async {
    final response = await dio.get(
      '/api/products/store/$storeId/isnot_deleted',
      queryParameters: {
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      },
    );
    return _parseList(response.data);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> payload) async {
    final response = await dio.post('/api/products', data: payload);
    return _parseMap(response.data);
  }

  Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> payload) async {
    final response = await dio.put('/api/products/$productId', data: payload);
    return _parseMap(response.data);
  }

  Future<void> deleteProduct(String productId) async {
    await dio.put('/api/products/$productId/soft-delete');
  }

  Future<List<Map<String, dynamic>>> uploadImages({
    required String productId,
    required List<MultipartFile> files,
    bool replace = false,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('productId', productId));
    for (final file in files) {
      formData.files.add(MapEntry('files', file));
    }

    final endpoint = '/api/product-images/upload/$productId';
    final response = replace ? await dio.post(endpoint, data: formData) : await dio.post(endpoint, data: formData);
    return _parseList(response.data);
  }

  Future<List<Map<String, dynamic>>> searchProducts({
    required String keyword,
  }) async {
    final response = await dio.get(
      '/api/products/search',
      queryParameters: {
        'q': keyword,
      },
    );
    return _parseList(response.data);
  }

  Future<List<Map<String, dynamic>>> getProductImages(String productId) async {
    final response = await dio.get('/api/product-images/product/$productId');
    return _parseList(response.data);
  }

  Future<Map<String, dynamic>> searchByImage({
    required String base64Image,
  }) async {
    final response = await dio.post(
      '/api/products/search-by-image',
      data: {
        'base64_image_string': base64Image,
      },
    );
    return _parseMap(response.data);
  }

  List<Map<String, dynamic>> _parseList(dynamic source) {
    if (source == null) return const [];
    if (source is List) {
      return source.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (source is Map) {
      if (source.containsKey('data')) {
        return _parseList(source['data']);
      }
      return [Map<String, dynamic>.from(source)];
    }
    return const [];
  }

  Map<String, dynamic> _parseMap(dynamic source) {
    if (source == null) return <String, dynamic>{};
    if (source is Map<String, dynamic>) {
      if (source.containsKey('data') && source['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(source['data']);
      }
      return source;
    }
    if (source is List && source.isNotEmpty && source.first is Map<String, dynamic>) {
      return Map<String, dynamic>.from(source.first as Map);
    }
    return <String, dynamic>{};
  }
}
