import '../../../utils/result.dart';
import '../../repositories/wishlist_repository.dart';

class AddStoreToWishlist {
  final WishlistRepository repository;

  AddStoreToWishlist(this.repository);

  Future<Result<void>> call({
    required String customerId,
    required int storeId,
  }) {
    return repository.addStoreToWishlist(customerId: customerId, storeId: storeId);
  }
}
