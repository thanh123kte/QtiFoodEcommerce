import '../../../utils/result.dart';
import '../../entities/cart_item.dart';
import '../../repositories/cart_repository.dart';

class AddProductToCart {
  final CartRepository repository;

  AddProductToCart(this.repository);

  Future<Result<CartItem>> call({
    required String customerId,
    required String productId,
    required int quantity,
  }) {
    return repository.addToCart(
      customerId: customerId,
      productId: productId,
      quantity: quantity,
    );
  }
}
