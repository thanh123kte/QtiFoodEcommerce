import '../../../utils/result.dart';
import '../../entities/product.dart';
import '../../entities/update_product_input.dart';
import '../../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Result<Product>> call(String productId, UpdateProductInput input) {
    return repository.updateProduct(productId, input);
  }
}
