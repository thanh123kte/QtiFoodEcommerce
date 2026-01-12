import 'package:dio/dio.dart';

import '../../domain/entities/store.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/wishlist_local.dart';
import '../datasources/remote/wishlist_remote.dart';
import '../models/store_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemote remote;
  final WishlistLocal? local;

  WishlistRepositoryImpl(this.remote, [this.local]);

  @override
  Future<Result<void>> addStoreToWishlist({
    required String customerId,
    required int storeId,
  }) async {
    try {
      await remote.addStoreToWishlist(customerId: customerId, storeId: storeId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> removeStoreFromWishlist({
    required String customerId,
    required int storeId,
  }) async {
    try {
      await remote.removeStoreFromWishlist(customerId: customerId, storeId: storeId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<bool>> isStoreInWishlist({
    required String customerId,
    required int storeId,
  }) async {
    try {
      final result = await remote.isStoreInWishlist(customerId: customerId, storeId: storeId);
      return Ok(result);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Store>>> getWishlist({required String customerId}) async {
    List<StoreModel> cached = const [];
    try {
      cached = await (local?.getStores(customerId) ?? Future.value(const []));
    } catch (_) {
      cached = const [];
    }

    try {
      final json = await remote.getWishlist(customerId: customerId);
      final stores = json
          .map(_extractStoreJson)
          .where((map) => map != null)
          .map((map) => StoreModel.fromJson(map!))
          .toList();
      if (local != null) {
        await local!.saveStores(customerId, stores);
      }
      return Ok(stores.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  Map<String, dynamic>? _extractStoreJson(Map<String, dynamic> source) {
    if (source.containsKey('store') && source['store'] is Map) {
      return Map<String, dynamic>.from(source['store'] as Map);
    }
    if (source.containsKey('storeDto') && source['storeDto'] is Map) {
      return Map<String, dynamic>.from(source['storeDto'] as Map);
    }

    // Some APIs may return flattened store info inside wishlist item.
    final id = source['storeId'] ?? source['store_id'] ?? source['id'];
    final name = source['storeName'] ?? source['name'];
    final address = source['storeAddress'] ?? source['address'];
    final description = source['storeDescription'] ?? source['description'];
    final image = source['storeImage'] ?? source['imageUrl'] ?? source['image_url'];

    if (id != null || name != null || address != null || image != null) {
      return {
        'id': id?.toString() ?? '',
        'ownerId': source['ownerId'] ?? source['owner_id'] ?? '',
        'name': name ?? '',
        'address': address ?? '',
        'description': description ?? '',
        'imageUrl': image ?? '',
        'latitude': source['latitude'],
        'longitude': source['longitude'],
        'status': source['status'],
        'opStatus': source['opStatus'],
        'openTime': source['openTime'],
        'closeTime': source['closeTime'],
        'createdAt': source['createdAt'],
        'updatedAt': source['updatedAt'],
      };
    }

    return source;
  }
}
