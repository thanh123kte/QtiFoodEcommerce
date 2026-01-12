import 'package:dio/dio.dart';

import '../../domain/entities/create_store_input.dart';
import '../../domain/entities/nearby_store.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/update_store_input.dart';
import '../../domain/repositories/store_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/store_local.dart';
import '../datasources/remote/store_remote.dart';
import '../models/nearby_store_model.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemote remote;
  final StoreLocal local;

  StoreRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<Store>> createStore(CreateStoreInput input) async {
    try {
      final json = await remote.createStore(input.toJson());
      final model = StoreModel.fromJson(json!);
      await local.saveStore(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Store?>> getStoreByOwner(String ownerId) async {
    final cached = await local.getStoreByOwner(ownerId);
    try {
      final json = await remote.getStoreByOwner(ownerId);
      if (json == null) {
        await local.removeStoreByOwner(ownerId);
        return const Ok(null);
      }
      final model = StoreModel.fromJson(json);
      await local.saveStore(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await local.removeStoreByOwner(ownerId);
        return const Ok(null);
      }
      if (cached != null) {
        return Ok(cached.toEntity());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached != null) {
        return Ok(cached.toEntity());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Store?>> getStore(int storeId) async {
    final cached = await local.getStoreById(storeId);
    try {
      final json = await remote.getStore(storeId);
      if (json == null) {
        await local.removeStoreById(storeId);
        return const Ok(null);
      }
      final model = StoreModel.fromJson(json);
      await local.saveStore(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      if (cached != null) {
        return Ok(cached.toEntity());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached != null) {
        return Ok(cached.toEntity());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Store>> updateStore(int storeId, UpdateStoreInput input) async {
    try {
      final json = await remote.updateStore(storeId, input.toJson());
      if (json == null) {
        return const Err('Khong nhan duoc thong tin cua hang sau khi cap nhat');
      }
      final model = StoreModel.fromJson(json);
      await local.saveStore(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> incrementView(int storeId) async {
    try {
      await remote.incrementView(storeId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Store>> uploadStoreImage(int storeId, String imagePath) async {
    try {
      final file = await MultipartFile.fromFile(imagePath);
      final json = await remote.uploadStoreImage(storeId: storeId, file: file);
      if (json == null) {
        return const Err('Không nhận được thông tin cửa hàng sau khi tải ảnh');
      }
      final model = StoreModel.fromJson(json);
      await local.saveStore(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<NearbyStore>>> getNearbyStores({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final jsonList = await remote.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
      );
      final items = jsonList.map(NearbyStoreModel.fromJson).map((e) => e.toEntity()).toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  String _readMessage(DioException exception) {
    return exception.response?.data?.toString() ?? exception.message ?? 'API error';
  }
}
