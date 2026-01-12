import '../../../utils/result.dart';
import '../../entities/address.dart';
import '../../repositories/address_repository.dart';

class GetAddresses {
  final AddressRepository repository;

  GetAddresses(this.repository);

  Future<Result<List<Address>>> call(String userId, {bool forceRefresh = false}) {
    return forceRefresh
        ? repository.refreshAddresses(userId)
        : repository.getAddresses(userId);
  }
}
