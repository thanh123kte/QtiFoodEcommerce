import '../../utils/result.dart';
import '../entities/create_product_input.dart';
import '../entities/product.dart';
import '../entities/product_image_file.dart';
import '../entities/update_product_input.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({
    required int storeId,
    String? keyword,
  });

  Future<Result<Product>> createProduct(CreateProductInput input);

  Future<Result<Product>> updateProduct(String productId, UpdateProductInput input);

  Future<Result<void>> deleteProduct(String productId);

  Future<Result<List<ProductImage>>> uploadProductImages(
    String productId,
    List<ProductImageFile> files, {
    bool replace = false,
  });

  Future<Result<List<ProductImage>>> getProductImages(String productId);

  Future<Result<List<Product>>> getFeaturedProducts({
    int page = 1,
    int limit = 10,
  });

  Future<Result<List<Product>>> searchProducts({
    required String keyword,
    int page = 1,
    int limit = 20,
  });

  Future<Result<List<String>>> searchByImage({
    required String base64Image,
  });
}
