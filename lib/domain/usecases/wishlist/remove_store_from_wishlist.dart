import '../../../utils/result.dart';
import '../../repositories/wishlist_repository.dart';

class RemoveStoreFromWishlist {
  final WishlistRepository repository;

  RemoveStoreFromWishlist(this.repository);

  Future<Result<void>> call({
    required String customerId,
    required int storeId,
  }) {
    return repository.removeStoreFromWishlist(customerId: customerId, storeId: storeId);
  }
}
