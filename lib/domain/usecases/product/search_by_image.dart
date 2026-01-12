import '../../../utils/result.dart';
import '../../repositories/product_repository.dart';

class SearchByImage {
  final ProductRepository repository;

  SearchByImage(this.repository);

  Future<Result<List<String>>> call({
    required String base64Image,
  }) {
    return repository.searchByImage(base64Image: base64Image);
  }
}
