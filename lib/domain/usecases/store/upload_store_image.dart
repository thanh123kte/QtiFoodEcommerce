import '../../repositories/store_repository.dart';
import '../../../utils/result.dart';

class UploadStoreImage {
  final StoreRepository repository;

  UploadStoreImage(this.repository);

  Future<Result<String>> call(int storeId, String imagePath) async {
    final result = await repository.uploadStoreImage(storeId, imagePath);
    return result.when(
      ok: (store) => Ok(store.imageUrl),
      err: (message) => Err(message),
    );
  }
}
