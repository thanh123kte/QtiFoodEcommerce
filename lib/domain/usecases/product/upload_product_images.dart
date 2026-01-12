import '../../../utils/result.dart';
import '../../entities/product.dart';
import '../../entities/product_image_file.dart';
import '../../repositories/product_repository.dart';

class UploadProductImages {
  final ProductRepository repository;

  UploadProductImages(this.repository);

  Future<Result<List<ProductImage>>> call(
    String productId,
    List<ProductImageFile> files, {
    bool replace = false,
  }) {
    return repository.uploadProductImages(productId, files, replace: replace);
  }
}
