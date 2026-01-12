import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/nearby_store.dart';
import '../../repositories/store_repository.dart';

class GetNearbyStores {
  final StoreRepository repository;

  GetNearbyStores(this.repository);

  Future<Result<List<NearbyStore>>> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
