import 'package:dio/dio.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/cart_local.dart';
import '../datasources/remote/cart_remote.dart';
import '../datasources/remote/product_remote.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemote remote;
  final CartLocal local;
  final ProductRemote productRemote;

  CartRepositoryImpl(this.remote, this.local, this.productRemote);

  @override
  Future<Result<List<CartItem>>> getCartItems({
    required String customerId,
    bool forceRefresh = false,
  }) async {
    List<CartItemModel> cached = const [];
    try {
      cached = await local.getCartItems(customerId);
    } catch (_) {
      cached = const [];
    }
    if (!forceRefresh && cached.isNotEmpty) {
      final resolved = await _ensureProductImages(customerId, cached);
      return Ok(resolved.map((model) => model.toEntity()).toList());
    }
    try {
      final json = await remote.getCartItems(customerId);
      var models = json.map((item) => CartItemModel.fromJson(item)).toList();
      models = await _ensureProductImages(customerId, models);
      await local.saveCartItems(customerId, models);
      return Ok(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        final resolved = await _ensureProductImages(customerId, cached);
        return Ok(resolved.map((model) => model.toEntity()).toList());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        final resolved = await _ensureProductImages(customerId, cached);
        return Ok(resolved.map((model) => model.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<CartItem>> addToCart({
    required String customerId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final json = await remote.addToCart(
        customerId: customerId,
        payload: {
          'productId': int.tryParse(productId) ?? productId,
          'quantity': quantity,
        },
      );
      var item = CartItemModel.fromJson(json);
      item = await _ensureProductImage(customerId, item);
      await local.upsertCartItem(customerId, item);
      return Ok(item.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<CartItem>> updateCartItem({
    required String customerId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final json = await remote.updateCartItem(
        customerId: customerId,
        cartItemId: cartItemId,
        payload: {
          'quantity': quantity,
        },
      );
      var item = CartItemModel.fromJson(json);
      item = await _ensureProductImage(customerId, item);
      await local.upsertCartItem(customerId, item);
      return Ok(item.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> removeCartItem({
    required String customerId,
    required String cartItemId,
  }) async {
    try {
      await remote.removeCartItem(customerId: customerId, cartItemId: cartItemId);
      await local.removeCartItem(customerId, cartItemId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<List<CartItemModel>> _ensureProductImages(
    String customerId,
    List<CartItemModel> items,
  ) async {
    bool updated = false;
    final futures = items.map((item) async {
      final resolved = await _ensureProductImage(customerId, item, persist: false);
      if (!identical(resolved, item)) {
        updated = true;
      }
      return resolved;
    });
    final resolvedItems = await Future.wait(futures);
    if (updated) {
      await local.saveCartItems(customerId, resolvedItems);
    }
    return resolvedItems;
  }

  Future<CartItemModel> _ensureProductImage(
    String customerId,
    CartItemModel item, {
    bool persist = true,
  }) async {
    final currentImage = item.product.imageUrl;
    if (currentImage != null && currentImage.isNotEmpty) {
      return item;
    }
    final productId = item.product.id;
    if (productId.isEmpty) return item;
    try {
      final json = await productRemote.getProductImages(productId);
      if (json.isEmpty) return item;
      final images = json.map(ProductImageModel.fromJson).toList();
      if (images.isEmpty) return item;
      ProductImageModel? primary;
      try {
        primary = images.firstWhere((image) => image.isPrimary == true);
      } catch (_) {
        primary = images.first;
      }
      if (primary.imageUrl.isEmpty) {
        return item;
      }
      final updatedProduct = item.product.copyWith(imageUrl: primary.imageUrl);
      final updatedItem = item.copyWith(product: updatedProduct);
      if (persist) {
        await local.upsertCartItem(customerId, updatedItem);
      }
      return updatedItem;
    } catch (_) {
      return item;
    }
  }

  String _readMessage(DioException exception) {
    return exception.response?.data?.toString() ?? exception.message ?? 'API error';
  }
}
