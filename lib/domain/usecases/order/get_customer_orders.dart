import '../../../utils/result.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class GetCustomerOrders {
  final OrderRepository repository;

  GetCustomerOrders(this.repository);

  Future<Result<List<Order>>> call(String customerId) {
    return repository.getOrdersByCustomer(customerId);
  }
}
