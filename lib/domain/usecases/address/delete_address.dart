import '../../../utils/result.dart';
import '../../entities/delete_address_input.dart';
import '../../repositories/address_repository.dart';

class DeleteAddress {
  final AddressRepository repository;

  DeleteAddress(this.repository);

  Future<Result<bool>> call(DeleteAddressInput input) {
    return repository.deleteAddress(input);
  }
}
