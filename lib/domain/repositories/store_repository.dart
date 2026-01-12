import '../../utils/result.dart';
import '../entities/create_store_input.dart';
import '../entities/nearby_store.dart';
import '../entities/store.dart';
import '../entities/update_store_input.dart';

abstract class StoreRepository {
  Future<Result<Store>> createStore(CreateStoreInput input);
  Future<Result<Store?>> getStoreByOwner(String ownerId);
  Future<Result<Store?>> getStore(int storeId);
  Future<Result<Store>> updateStore(int storeId, UpdateStoreInput input);
  Future<Result<void>> incrementView(int storeId);
  Future<Result<Store>> uploadStoreImage(int storeId, String imagePath);
  Future<Result<List<NearbyStore>>> getNearbyStores({
    required double latitude,
    required double longitude,
  });
}
