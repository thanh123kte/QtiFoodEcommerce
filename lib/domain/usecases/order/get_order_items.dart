import '../../../utils/result.dart';
import '../../entities/order_item.dart';
import '../../repositories/order_repository.dart';

class GetOrderItems {
  final OrderRepository repository;

  GetOrderItems(this.repository);

  Future<Result<List<OrderItem>>> call(int orderId) {
    return repository.getOrderItems(orderId);
  }
}
