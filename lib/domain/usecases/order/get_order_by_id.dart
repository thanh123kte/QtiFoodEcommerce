import '../../../utils/result.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class GetOrderById {
  final OrderRepository repository;

  GetOrderById(this.repository);

  Future<Result<Order>> call(int orderId) {
    return repository.getOrderById(orderId);
  }
}
