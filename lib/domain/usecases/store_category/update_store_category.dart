import '../../../utils/result.dart';
import '../../entities/create_store_category_input.dart';
import '../../entities/store_category.dart';
import '../../repositories/store_category_repository.dart';

class UpdateStoreCategory {
  final StoreCategoryRepository repository;

  UpdateStoreCategory(this.repository);

  Future<Result<StoreCategory>> call(
    int id,
    UpdateStoreCategoryInput input,
  ) {
    return repository.updateCategory(id, input);
  }
}
