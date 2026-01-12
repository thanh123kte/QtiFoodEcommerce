import 'package:dio/dio.dart';

class CartRemote {
  final Dio dio;

  CartRemote(this.dio);

  Future<List<Map<String, dynamic>>> getCartItems(String customerId) async {
    final response = await dio.get('/api/cart/$customerId');
    return _parseList(response.data);
  }

  Future<Map<String, dynamic>> addToCart({
    required String customerId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await dio.post('/api/cart/$customerId', data: payload);
    return _parseMap(response.data);
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String customerId,
    required String cartItemId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await dio.put('/api/cart/$customerId/items/$cartItemId', data: payload);
    return _parseMap(response.data);
  }

  Future<void> removeCartItem({
    required String customerId,
    required String cartItemId,
  }) async {
    await dio.delete('/api/cart/$customerId/items/$cartItemId');
  }

  List<Map<String, dynamic>> _parseList(dynamic source) {
    if (source == null) return const [];
    if (source is List) {
      return source.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(growable: false);
    }
    if (source is Map) {
      if (source['data'] is List) {
        return _parseList(source['data']);
      }
      return [Map<String, dynamic>.from(source)];
    }
    return const [];
  }

  Map<String, dynamic> _parseMap(dynamic source) {
    if (source == null) return <String, dynamic>{};
    if (source is Map<String, dynamic>) {
      if (source['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(source['data'] as Map<String, dynamic>);
      }
      return source;
    }
    if (source is List && source.isNotEmpty && source.first is Map<String, dynamic>) {
      return Map<String, dynamic>.from(source.first as Map<String, dynamic>);
    }
    return <String, dynamic>{};
  }
}
