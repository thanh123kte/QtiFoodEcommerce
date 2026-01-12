import '../../../utils/result.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class CancelOrder {
  final OrderRepository repository;

  CancelOrder(this.repository);

  Future<Result<void>> call(Order order) {
    return repository.updateOrderStatus(
      order: order,
      status: 'CANCELLED',
    );
  }
}
