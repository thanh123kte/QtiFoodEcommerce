import '../../../utils/result.dart';
import '../../entities/create_store_category_input.dart';
import '../../entities/store_category.dart';
import '../../repositories/store_category_repository.dart';

class CreateStoreCategory {
  final StoreCategoryRepository repository;

  CreateStoreCategory(this.repository);

  Future<Result<StoreCategory>> call(CreateStoreCategoryInput input) {
    return repository.createCategory(input);
  }
}
