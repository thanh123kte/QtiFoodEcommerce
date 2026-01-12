import 'package:dio/dio.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/create_address_input.dart';
import '../../domain/entities/delete_address_input.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/entities/update_address_input.dart';
import '../../domain/repositories/address_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/address_local.dart';
import '../datasources/remote/address_remote.dart';
import '../datasources/remote/place_suggestion_remote.dart';
import '../models/address_model.dart';
import '../models/place_suggestion_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemote remote;
  final AddressLocal local;
  final PlaceSuggestionRemote suggestionRemote;

  AddressRepositoryImpl(
    this.remote,
    this.local,
    this.suggestionRemote,
  );

  @override
  Future<Result<List<Address>>> getAddresses(String userId) async {
    try {
      final cached = await local.getAddresses(userId);
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      // ignore local cache errors, still try remote
    }
    return refreshAddresses(userId);
  }

  @override
  Future<Result<List<Address>>> refreshAddresses(String userId) async {
    try {
      final jsonList = await remote.getAddressesByUser(userId);
      final models = jsonList.map(AddressModel.fromJson).toList();
      try {
        await local.saveAddresses(userId, models);
      } catch (_) {
        // swallow cache save errors
      }
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Address>> getAddressById(String addressId) async {
    try {
      final cached = await local.findAddressById(addressId);
      if (cached != null) {
        return Ok(cached.toEntity());
      }
    } catch (_) {
      // ignore cache errors, fallback to remote
    }

    try {
      final json = await remote.getAddressById(addressId);
      final model = AddressModel.fromJson(json);
      try {
        await local.upsertAddress(model);
      } catch (_) {
        // ignore cache update errors
      }
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Address>> createAddress(CreateAddressInput input) async {
    try {
      final json = await remote.createAddress(input.toJson());
      final model = AddressModel.fromJson(json);

      try {
        final cached = await local.getAddresses(input.userId);
        final updated = <AddressModel>[
          model,
          ...cached.where((item) => item.id != model.id),
        ];
        await local.saveAddresses(input.userId, updated);
      } catch (_) {
        // ignore cache save errors
      }

      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Address>> updateAddress(UpdateAddressInput input) async {
    try {
      final json = await remote.updateAddress(input.id, input.toJson());
      final model = AddressModel.fromJson(json);
      final userId = model.userId;

      try {
        final cached = await local.getAddresses(userId);
        final updated = <AddressModel>[
          model,
          ...cached.where((item) => item.id != model.id),
        ];
        await local.saveAddresses(userId, updated);
      } catch (_) {
        // ignore cache save errors
      }

      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<bool>> deleteAddress(DeleteAddressInput input) async {
    try {
      await remote.deleteAddress(input.id);
      try {
       final removed = await local.removeAddressById(input.id);
        return Ok(removed);
      } catch (_) {
        // ignore cache remove errors
      }
      return const Ok(true);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<PlaceSuggestion>>> searchPlaceSuggestions(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) {
      return Ok(const <PlaceSuggestion>[]);
    }
    if (suggestionRemote.apiKey.isEmpty) {
      return Err('Place suggestion API key is not configured');
    }
    try {
      final jsonList = await suggestionRemote.fetchSuggestions(
        query: query,
        latitude: latitude,
        longitude: longitude,
        limit: limit,
      );
      final models = jsonList.map(PlaceSuggestionModel.fromJson).toList();
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
