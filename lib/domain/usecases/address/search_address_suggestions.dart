import '../../../utils/result.dart';
import '../../entities/place_suggestion.dart';
import '../../repositories/address_repository.dart';

class SearchAddressSuggestions {
  final AddressRepository repository;

  SearchAddressSuggestions(this.repository);

  Future<Result<List<PlaceSuggestion>>> call(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  }) {
    return repository.searchPlaceSuggestions(
      query,
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );
  }
}

