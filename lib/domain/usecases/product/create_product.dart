import '../../../utils/result.dart';
import '../../entities/create_product_input.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Result<Product>> call(CreateProductInput input) {
    return repository.createProduct(input);
  }
}
