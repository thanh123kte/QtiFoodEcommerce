import '../../../utils/result.dart';
import '../../repositories/order_repository.dart';
import '../../entities/order.dart';

class UpdateOrderStatus {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<Result<void>> call({
    required Order order,
    required String status,
  }) {
    return repository.updateOrderStatus(order: order, status: status);
  }
}
