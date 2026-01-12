import '../../entities/product.dart';
import '../../repositories/product_repository.dart';
import '../../../utils/result.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<Result<List<Product>>> call({
    required String keyword,
    int page = 1,
    int limit = 20,
  }) {
    return repository.searchProducts(keyword: keyword, page: page, limit: limit);
  }
}
