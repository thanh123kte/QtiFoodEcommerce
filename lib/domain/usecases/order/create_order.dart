import '../../../utils/result.dart';
import '../../entities/create_order_input.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<Result<Order>> call(CreateOrderInput input) {
    return repository.createOrder(input);
  }
}
