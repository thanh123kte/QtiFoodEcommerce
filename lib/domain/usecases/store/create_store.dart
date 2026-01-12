import '../../../utils/result.dart';
import '../../entities/create_store_input.dart';
import '../../entities/store.dart';
import '../../repositories/store_repository.dart';

class CreateStore {
  final StoreRepository repository;

  CreateStore(this.repository);

  Future<Result<Store>> call(CreateStoreInput input) {
    return repository.createStore(input);
  }
}
