import '../../../utils/result.dart';
import '../../entities/address.dart';
import '../../repositories/address_repository.dart';

class GetAddressById {
  final AddressRepository repository;

  GetAddressById(this.repository);

  Future<Result<Address>> call(String addressId) {
    return repository.getAddressById(addressId);
  }
}
