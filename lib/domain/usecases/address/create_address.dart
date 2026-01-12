import '../../../utils/result.dart';
import '../../entities/address.dart';
import '../../entities/create_address_input.dart';
import '../../repositories/address_repository.dart';

class CreateAddress {
  final AddressRepository repository;

  CreateAddress(this.repository);

  Future<Result<Address>> call(CreateAddressInput input) {
    return repository.createAddress(input);
  }
}

