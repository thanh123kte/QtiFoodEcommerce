import '../../../utils/result.dart';
import '../../entities/create_order_input.dart';
import '../../repositories/order_repository.dart';

class CreateOrderItem {
  final OrderRepository repository;

  CreateOrderItem(this.repository);

  Future<Result<void>> call(CreateOrderItemInput input) {
    return repository.createOrderItem(input);
  }
}
