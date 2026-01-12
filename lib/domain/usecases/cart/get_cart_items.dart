import '../../../utils/result.dart';
import '../../entities/cart_item.dart';
import '../../repositories/cart_repository.dart';

class GetCartItems {
  final CartRepository repository;

  GetCartItems(this.repository);

  Future<Result<List<CartItem>>> call(
    String customerId, {
    bool forceRefresh = false,
  }) {
    return repository.getCartItems(
      customerId: customerId,
      forceRefresh: forceRefresh,
    );
  }
}
