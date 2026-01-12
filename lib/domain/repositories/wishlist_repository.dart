import '../../utils/result.dart';
import '../entities/store.dart';

abstract class WishlistRepository {
  Future<Result<void>> addStoreToWishlist({
    required String customerId,
    required int storeId,
  });

  Future<Result<void>> removeStoreFromWishlist({
    required String customerId,
    required int storeId,
  });

  Future<Result<bool>> isStoreInWishlist({
    required String customerId,
    required int storeId,
  });

  Future<Result<List<Store>>> getWishlist({required String customerId});
}
