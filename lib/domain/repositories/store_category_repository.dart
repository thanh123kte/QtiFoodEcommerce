import '../../utils/result.dart';
import '../entities/create_store_category_input.dart';
import '../entities/store_category.dart';

abstract class StoreCategoryRepository {
  Future<Result<List<StoreCategory>>> getCategoriesByStore(int storeId);
  Future<Result<StoreCategory>> createCategory(CreateStoreCategoryInput input);
  Future<Result<StoreCategory>> updateCategory(
    int id,
    UpdateStoreCategoryInput input,
  );
  Future<Result<void>> deleteCategory(int id);
}
