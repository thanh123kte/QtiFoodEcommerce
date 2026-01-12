import '../../../utils/result.dart';
import '../../entities/address.dart';
import '../../entities/update_address_input.dart';
import '../../repositories/address_repository.dart';

class UpdateAddress {
  final AddressRepository repository;

  UpdateAddress(this.repository);

  Future<Result<Address>> call(UpdateAddressInput input) {
    return repository.updateAddress(input);
  }
}

