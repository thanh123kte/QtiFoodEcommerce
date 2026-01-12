import '../../utils/result.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Result<List<CartItem>>> getCartItems({
    required String customerId,
    bool forceRefresh = false,
  });

  Future<Result<CartItem>> addToCart({
    required String customerId,
    required String productId,
    required int quantity,
  });

  Future<Result<CartItem>> updateCartItem({
    required String customerId,
    required String cartItemId,
    required int quantity,
  });

  Future<Result<void>> removeCartItem({
    required String customerId,
    required String cartItemId,
  });
}
