import '../../utils/result.dart';
import '../entities/address.dart';
import '../entities/create_address_input.dart';
import '../entities/delete_address_input.dart';
import '../entities/place_suggestion.dart';
import '../entities/update_address_input.dart';

abstract class AddressRepository {
  Future<Result<List<Address>>> getAddresses(String userId);
  Future<Result<List<Address>>> refreshAddresses(String userId);
  Future<Result<Address>> getAddressById(String addressId);
  Future<Result<Address>> createAddress(CreateAddressInput input);
  Future<Result<Address>> updateAddress(UpdateAddressInput input);
  Future<Result<bool>> deleteAddress(DeleteAddressInput input);
  Future<Result<List<PlaceSuggestion>>> searchPlaceSuggestions(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  });
}
