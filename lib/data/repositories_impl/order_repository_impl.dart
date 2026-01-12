import 'package:dio/dio.dart';

import '../../domain/entities/create_order_input.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/sales_stats.dart';
import '../../domain/entities/top_product_stat.dart';
import '../../domain/repositories/order_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/order_remote.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/sales_stats_model.dart';
import '../models/top_product_stat_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemote remote;

  OrderRepositoryImpl(this.remote);

  @override
  Future<Result<Order>> createOrder(CreateOrderInput input) async {
    print('[OrderRepo] createOrder START');
    print('[OrderRepo] storeId: ${input.storeId}, customerId: ${input.customerId}');
    print('[OrderRepo] totalAmount: ${input.totalAmount}, shippingFee: ${input.shippingFee}');
    print('[OrderRepo] items count: ${input.items.length}');
    
    try {
      final json = await remote.createOrder(input.toJson());
      print('[OrderRepo] createOrder SUCCESS - raw response keys: ${json.keys.toList()}');
      print('[OrderRepo] Order ID: ${json['id']}');
      
      final model = OrderModel.fromJson(json);
      final result = Ok(model.toEntity());
      print('[OrderRepo] createOrder returning Order entity');
      return result;
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'API error';
      print('[OrderRepo] createOrder DioException - status: ${e.response?.statusCode}');
      print('[OrderRepo] createOrder DioException - message: $msg');
      return Err(msg);
    } catch (e) {
      print('[OrderRepo] createOrder Exception: $e');
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> createOrderItem(CreateOrderItemInput input) async {
    print('[OrderRepo] createOrderItem START');
    print('[OrderRepo] orderId: ${input.orderId}, productId: ${input.productId}');
    print('[OrderRepo] quantity: ${input.quantity}, price: ${input.price}');
    
    try {
      await remote.createOrderItem(input.toJson());
      print('[OrderRepo] createOrderItem SUCCESS');
      return const Ok(null);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'API error';
      print('[OrderRepo] createOrderItem DioException - status: ${e.response?.statusCode}');
      print('[OrderRepo] createOrderItem DioException - message: $msg');
      return Err(msg);
    } catch (e) {
      print('[OrderRepo] createOrderItem Exception: $e');
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> createOrderItemsBulk(List<CreateOrderItemInput> items) async {
    print('[OrderRepo] createOrderItemsBulk START');
    print('[OrderRepo] items count: ${items.length}');
    
    try {
      final payload = items.map((item) => item.toJson()).toList();
      await remote.createOrderItemsBulk(payload);
      print('[OrderRepo] createOrderItemsBulk SUCCESS');
      return const Ok(null);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'API error';
      print('[OrderRepo] createOrderItemsBulk DioException - status: ${e.response?.statusCode}');
      print('[OrderRepo] createOrderItemsBulk DioException - message: $msg');
      return Err(msg);
    } catch (e) {
      print('[OrderRepo] createOrderItemsBulk Exception: $e');
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Order>>> getOrdersByCustomer(String customerId) async {
    try {
      final json = await remote.getOrdersByCustomer(customerId);
      final models = json.map(OrderModel.fromJson).toList();
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Order>>> getOrdersByStore(int storeId) async {
    try {
      final json = await remote.getOrdersByStore(storeId);
      final models = json.map(OrderModel.fromJson).toList();
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<OrderItem>>> getOrderItems(int orderId) async {
    try {
      final json = await remote.getOrderItems(orderId);
      final models = json.map(OrderItemModel.fromJson).toList();
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Order>> getOrderById(int orderId) async {
    try {
      final json = await remote.getOrderById(orderId);
      final model = OrderModel.fromJson(json);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> updateOrderStatus({
    required Order order,
    required String status,
  }) async {
    try {
      // remote.updateOrderStatus giờ dùng đúng API mới:
      // PATCH /api/orders/{id}/status?status=...
      await remote.updateOrderStatus(
        order.id,
        status,              // PENDING / CONFIRMED / PREPARING / ...
      );

      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> assignDriver(int orderId) async {
    try {
      await remote.assignDriver(orderId);
      return const Ok(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['messages'] is List && (data['messages'] as List).isNotEmpty) {
        return Err((data['messages'] as List).join('\n'));
      }
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<SalesStats>> getSalesStats({
    required int storeId,
    required String period,
  }) async {
    try {
      final json = await remote.getSalesStats(storeId: storeId, period: period);
      final model = SalesStatsModel.fromJson(json);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<TopProductStat>>> getTopProducts({required int storeId}) async {
    try {
      final list = await remote.getTopProducts(storeId: storeId);
      final models = list.map((e) => TopProductStatModel.fromJson(e)).toList();
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
