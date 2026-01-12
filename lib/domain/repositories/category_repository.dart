import '../../utils/result.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Result<List<FatherCategory>>> getCategories();
}
