import '../../../utils/result.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetFeaturedProducts {
  final ProductRepository repository;

  const GetFeaturedProducts(this.repository);

  Future<Result<List<Product>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return repository.getFeaturedProducts(page: page, limit: limit);
  }
}
