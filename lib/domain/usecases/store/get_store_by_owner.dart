import '../../../utils/result.dart';
import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class GetStoreByOwner {
  final StoreRepository repository;

  GetStoreByOwner(this.repository);

  Future<Result<Store?>> call(String ownerId) {
    return repository.getStoreByOwner(ownerId);
  }
}
