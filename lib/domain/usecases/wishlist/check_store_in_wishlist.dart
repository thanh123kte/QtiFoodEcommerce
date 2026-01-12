import '../../../utils/result.dart';
import '../../repositories/wishlist_repository.dart';

class CheckStoreInWishlist {
  final WishlistRepository repository;

  CheckStoreInWishlist(this.repository);

  Future<Result<bool>> call({
    required String customerId,
    required int storeId,
  }) {
    return repository.isStoreInWishlist(customerId: customerId, storeId: storeId);
  }
}
