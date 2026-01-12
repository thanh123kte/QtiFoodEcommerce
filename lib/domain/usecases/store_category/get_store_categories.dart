import '../../../utils/result.dart';
import '../../entities/store_category.dart';
import '../../repositories/store_category_repository.dart';

class GetStoreCategories {
  final StoreCategoryRepository repository;

  GetStoreCategories(this.repository);

  Future<Result<List<StoreCategory>>> call(int storeId) {
    return repository.getCategoriesByStore(storeId);
  }
}
