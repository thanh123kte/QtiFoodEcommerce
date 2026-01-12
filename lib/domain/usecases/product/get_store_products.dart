import '../../../utils/result.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Result<List<Product>>> call({
    required int storeId,
    String? keyword,
  }) {
    return repository.getProducts(storeId: storeId, keyword: keyword);
  }
}
