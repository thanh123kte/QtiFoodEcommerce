import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/store.dart';
import '../../repositories/wishlist_repository.dart';
class GetWishlistStores {
  final WishlistRepository repository;

  GetWishlistStores(this.repository);

  Future<Result<List<Store>>> call({required String customerId}) {
    return repository.getWishlist(customerId: customerId);
  }
}
