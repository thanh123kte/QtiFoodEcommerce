import '../../../utils/result.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class GetStoreOrders {
  final OrderRepository repository;

  GetStoreOrders(this.repository);

  Future<Result<List<Order>>> call(int storeId) {
    return repository.getOrdersByStore(storeId);
  }
}
