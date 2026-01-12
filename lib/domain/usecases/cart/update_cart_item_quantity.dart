import '../../../utils/result.dart';
import '../../entities/cart_item.dart';
import '../../repositories/cart_repository.dart';

class UpdateCartItemQuantity {
  final CartRepository repository;

  UpdateCartItemQuantity(this.repository);

  Future<Result<CartItem>> call({
    required String customerId,
    required String cartItemId,
    required int quantity,
  }) {
    return repository.updateCartItem(
      customerId: customerId,
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }
}
