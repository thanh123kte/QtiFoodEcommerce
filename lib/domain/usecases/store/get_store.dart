import '../../../utils/result.dart';
import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class GetStore {
  final StoreRepository repository;

  GetStore(this.repository);

  Future<Result<Store?>> call(int storeId) {
    return repository.getStore(storeId);
  }
}
