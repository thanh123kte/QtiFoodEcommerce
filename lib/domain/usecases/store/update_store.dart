import '../../../utils/result.dart';
import '../../entities/store.dart';
import '../../entities/update_store_input.dart';
import '../../repositories/store_repository.dart';

class UpdateStore {
  final StoreRepository repository;

  UpdateStore(this.repository);

  Future<Result<Store>> call(int storeId, UpdateStoreInput input) {
    return repository.updateStore(storeId, input);
  }
}
