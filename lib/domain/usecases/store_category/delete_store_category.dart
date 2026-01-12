import '../../../utils/result.dart';
import '../../repositories/store_category_repository.dart';

class DeleteStoreCategory {
  final StoreCategoryRepository repository;

  DeleteStoreCategory(this.repository);

  Future<Result<void>> call(int id) {
    return repository.deleteCategory(id);
  }
}
