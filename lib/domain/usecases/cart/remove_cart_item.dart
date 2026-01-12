import '../../../utils/result.dart';
import '../../repositories/cart_repository.dart';

class RemoveCartItem {
  final CartRepository repository;

  RemoveCartItem(this.repository);

  Future<Result<void>> call({
    required String customerId,
    required String cartItemId,
  }) {
    return repository.removeCartItem(
      customerId: customerId,
      cartItemId: cartItemId,
    );
  }
}
