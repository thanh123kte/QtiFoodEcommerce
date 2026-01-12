import '../../../utils/result.dart';
import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<Result<List<FatherCategory>>> call() {
    return repository.getCategories();
  }
}
