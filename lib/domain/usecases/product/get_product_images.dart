import '../../../utils/result.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProductImages {
  final ProductRepository repository;

  GetProductImages(this.repository);

  Future<Result<List<ProductImage>>> call(String productId) {
    return repository.getProductImages(productId);
  }
}
