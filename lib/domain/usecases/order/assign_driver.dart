import '../../../utils/result.dart';
import '../../repositories/order_repository.dart';

class AssignDriver {
  final OrderRepository repository;

  AssignDriver(this.repository);

  Future<Result<void>> call(int orderId) {
    return repository.assignDriver(orderId);
  }
}
