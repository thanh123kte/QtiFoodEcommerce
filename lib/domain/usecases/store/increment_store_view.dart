import '../../repositories/store_repository.dart';
import '../../../utils/result.dart';

class IncrementStoreView {
  final StoreRepository repository;

  IncrementStoreView(this.repository);

  Future<Result<void>> call(int storeId) {
    return repository.incrementView(storeId);
  }
}
