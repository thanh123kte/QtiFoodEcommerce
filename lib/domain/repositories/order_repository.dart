import '../../utils/result.dart';
import '../entities/create_order_input.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../entities/sales_stats.dart';
import '../entities/top_product_stat.dart';

abstract class OrderRepository {
  Future<Result<Order>> createOrder(CreateOrderInput input);
  Future<Result<void>> createOrderItem(CreateOrderItemInput input);
  Future<Result<void>> createOrderItemsBulk(List<CreateOrderItemInput> items);

  Future<Result<List<Order>>> getOrdersByCustomer(String customerId);
  Future<Result<List<Order>>> getOrdersByStore(int storeId);
  Future<Result<Order>> getOrderById(int orderId);

  Future<Result<List<OrderItem>>> getOrderItems(int orderId);

  Future<Result<void>> updateOrderStatus({
    required Order order,
    required String status,
  });

  Future<Result<void>> assignDriver(int orderId);

  Future<Result<SalesStats>> getSalesStats({
    required int storeId,
    required String period,
  });

  Future<Result<List<TopProductStat>>> getTopProducts({
    required int storeId,
  });
}
