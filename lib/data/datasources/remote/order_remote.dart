import 'package:dio/dio.dart';

class OrderRemote {
  final Dio dio;

  OrderRemote(this.dio);

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    print('[OrderRemote] POST /api/orders');
    print('[OrderRemote] Payload: $payload');
    
    final response = await dio.post('/api/orders', data: payload);
    
    print('[OrderRemote] Response status: ${response.statusCode}');
    print('[OrderRemote] Response data: ${response.data}');
    
    return _parseObject(response);
  }

  Future<void> createOrderItem(Map<String, dynamic> payload) async {
    print('[OrderRemote] POST /api/order-items');
    print('[OrderRemote] Payload: $payload');
    
    final response = await dio.post('/api/order-items', data: payload);
    
    print('[OrderRemote] Response status: ${response.statusCode}');
    print('[OrderRemote] Response data: ${response.data}');
  }

  Future<void> createOrderItemsBulk(List<Map<String, dynamic>> items) async {
    print('[OrderRemote] POST /api/order-items/bulk');
    print('[OrderRemote] Payload: $items');
    
    final response = await dio.post('/api/order-items/bulk', data: items);
    
    print('[OrderRemote] Response status: ${response.statusCode}');
    print('[OrderRemote] Response data: ${response.data}');
  }

  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    final response = await dio.get('/api/orders/$orderId');
    return _parseObject(response);
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final response = await dio.get('/api/order-items/order/$orderId');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getOrdersByCustomer(String customerId) async {
    final response = await dio.get('/api/orders/customer/$customerId');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getOrdersByStore(int storeId) async {
    final response = await dio.get('/api/orders/store/$storeId');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await dio.patch(
      '/api/orders/$orderId/status',
      queryParameters: {
        'status': status, // PENDING | CONFIRMED | PREPARING | PREPARED | SHIPPING | DELIVERED | CANCELLED
      },
    );
  }

  Future<void> assignDriver(int orderId) async {
    await dio.post('/api/orders/$orderId/assign-driver');
  }

  Future<Map<String, dynamic>> getSalesStats({
    required int storeId,
    required String period,
  }) async {
    final response = await dio.get(
      '/api/orders/store/$storeId/sales-stats',
      queryParameters: {'period': period},
    );
    return _parseObject(response);
  }

  Future<List<Map<String, dynamic>>> getTopProducts({required int storeId}) async {
    final response = await dio.get('/api/orders/store/$storeId/top-products');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
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
