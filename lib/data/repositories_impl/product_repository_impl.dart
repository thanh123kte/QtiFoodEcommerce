import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../domain/entities/create_product_input.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_image_file.dart';
import '../../domain/entities/update_product_input.dart';
import '../../domain/repositories/product_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/product_local.dart';
import '../datasources/remote/product_remote.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemote remote;
  final ProductLocal local;
  static const String _customerFeedCacheKey = '__customer_feed__';
  static const String _searchPrefix = '__search__';

  ProductRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<List<Product>>> getProducts({
    required int storeId,
    String? keyword,
  }) async {
    List<ProductModel> cached = const <ProductModel>[];
    try {
      cached = await local.getProducts(storeId);
    } catch (_) {
      cached = const <ProductModel>[];
    }

    try {
      final json = await remote.getProductsByStore(storeId: storeId, keyword: keyword);
      final models = json.map(ProductModel.fromJson).toList();
      final enriched = await Future.wait(models.map(_attachImagesIfNeeded));
      await local.saveProducts(storeId, enriched);
      final stored = await local.getProducts(storeId);
      return Ok(_filterProducts(stored, keyword));
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(_filterProducts(cached, keyword));
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(_filterProducts(cached, keyword));
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Product>> createProduct(CreateProductInput input) async {
    try {
      final json = await remote.createProduct(input.toJson());
      final model = ProductModel.fromJson(json);
      await local.upsertProduct(model.storeId, model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Product>> updateProduct(String productId, UpdateProductInput input) async {
    try {
      final json = await remote.updateProduct(productId, input.toJson());
      final model = ProductModel.fromJson(json);
      await local.upsertProduct(model.storeId, model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteProduct(String productId) async {
    try {
      final storeId = await local.findStoreIdByProduct(productId);
      await remote.deleteProduct(productId);
      if (storeId != null) {
        await local.removeProduct(storeId, productId);
      }
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<ProductImage>>> uploadProductImages(
    String productId,
    List<ProductImageFile> files, {
    bool replace = false,
  }) async {
    if (files.isEmpty) {
      return const Ok([]);
    }
    try {
      final attachments = files
          .map(
            (file) => MultipartFile.fromBytes(
              file.bytes,
              filename: file.fileName,
            ),
          )
          .toList();
      final json = await remote.uploadImages(productId: productId, files: attachments, replace: replace);
      final models = json.map(ProductImageModel.fromJson).toList();
      await _appendImages(productId, models);
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<ProductImage>>> getProductImages(String productId) async {
    try {
      final json = await remote.getProductImages(productId);
      final models = json.map(ProductImageModel.fromJson).toList();
      await _appendImages(productId, models, replace: true);
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Product>>> getFeaturedProducts({
    int page = 1,
    int limit = 10,
  }) async {
    List<ProductModel> cached = const [];
    try {
      cached = await local.getProducts(_customerFeedCacheKey);
    } catch (_) {
      cached = const [];
    }

    try {
      final json = await remote.getFeaturedProducts();
      final models = json.map(ProductModel.fromJson).toList();
      final enriched = await Future.wait(models.map(_attachImagesIfNeeded));
      final merged = page == 1 ? enriched : _mergeProductLists(cached, enriched);
      await local.saveProducts(_customerFeedCacheKey, merged);
      return Ok(enriched.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      final fallback = _slicePage(cached, page, limit);
      if (fallback.isNotEmpty) {
        return Ok(fallback.map((model) => model.toEntity()).toList());
      }
      return Err(_readMessage(e));
    } catch (e) {
      final fallback = _slicePage(cached, page, limit);
      if (fallback.isNotEmpty) {
        return Ok(fallback.map((model) => model.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts({
    required String keyword,
    int page = 1,
    int limit = 20,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.isEmpty) {
      return const Ok([]);
    }
    final cacheKey = '$_searchPrefix${normalizedKeyword.toLowerCase()}';
    List<ProductModel> cached = const [];
    try {
      cached = await local.getProducts(cacheKey);
    } catch (_) {
      cached = const [];
    }

    try {
      final json = await remote.searchProducts(keyword: normalizedKeyword);
      final models = json.map(ProductModel.fromJson).toList();
      final enriched = await Future.wait(models.map(_attachImagesIfNeeded));
      await local.saveProducts(cacheKey, enriched);
      return Ok(enriched.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((model) => model.toEntity()).toList());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((model) => model.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  Future<ProductModel> _attachImagesIfNeeded(ProductModel model) async {
    if (model.images.isNotEmpty || model.id.isEmpty) {
      developer.log(
        'Product ${model.id} already has ${model.images.length} cached images',
        name: 'ProductRepository',
      );
      return model;
    }
    developer.log('Fetching images for product ${model.id}', name: 'ProductRepository');
    try {
      final json = await remote.getProductImages(model.id);
      final images = json.map(ProductImageModel.fromJson).toList();
      if (images.isEmpty) return model;
      developer.log(
        'Fetched ${images.length} images for product ${model.id}',
        name: 'ProductRepository',
      );
      return model.copyWith(images: images);
    } catch (error) {
      developer.log(
        'Failed to fetch images for product ${model.id}: $error',
        name: 'ProductRepository',
      );
      return model;
    }
  }

  Future<void> _appendImages(
    String productId,
    List<ProductImageModel> images, {
    bool replace = false,
  }) async {
    if (images.isEmpty) return;
    final storeId = await local.findStoreIdByProduct(productId);
    if (storeId == null) return;
    developer.log(
      'Appending ${images.length} images for product $productId (replace=$replace)',
      name: 'ProductRepository',
    );
    final products = await local.getProducts(storeId);
    final product = products.firstWhere(
      (item) => item.id == productId,
      orElse: () => ProductModel(
        id: productId,
        storeId: storeId,
        name: '',
        description: '',
        price: 0,
        discountPrice: 0,
        status: 'AVAILABLE',
      ),
    );
    final updatedImages = replace
        ? images
        : <ProductImageModel>[
            ...images,
            ...product.images.where(
              (existing) => images.every((incoming) => incoming.id != existing.id),
            ),
          ];
    final updated = product.copyWith(images: updatedImages);
    await local.upsertProduct(storeId, updated);
    developer.log(
      'Stored ${updatedImages.length} images for product $productId. urls=${updatedImages.map((e) => e.imageUrl).join(', ')}',
      name: 'ProductRepository',
    );
  }

  List<Product> _filterProducts(List<ProductModel> models, String? keyword) {
    Iterable<ProductModel> iterable = models;
    if (keyword != null && keyword.trim().isNotEmpty) {
      final lower = keyword.trim().toLowerCase();
      iterable = iterable.where(
        (model) =>
            model.name.toLowerCase().contains(lower) ||
            (model.description?.toLowerCase().contains(lower) ?? false),
      );
    }
    return iterable.map((model) => model.toEntity()).toList();
  }

  List<ProductModel> _mergeProductLists(
    List<ProductModel> existing,
    List<ProductModel> incoming,
  ) {
    final Map<String, ProductModel> map = {
      for (final product in existing) product.id: product,
    };
    for (final product in incoming) {
      map[product.id] = product;
    }
    return map.values.toList();
  }

  List<ProductModel> _slicePage(List<ProductModel> source, int page, int limit) {
    if (source.isEmpty) return const [];
    final normalizedPage = page < 1 ? 1 : page;
    final normalizedLimit = limit <= 0 ? 10 : limit;
    final start = (normalizedPage - 1) * normalizedLimit;
    if (start >= source.length) {
      return const [];
    }
    final end = math.min(start + normalizedLimit, source.length);
    return source.sublist(start, end);
  }

  String _readMessage(DioException exception) {
    return exception.response?.data?.toString() ?? exception.message ?? 'API error';
  }

  @override
  Future<Result<List<String>>> searchByImage({
    required String base64Image,
  }) async {
    try {
      final response = await remote.searchByImage(base64Image: base64Image);
      final productIds = List<String>.from(response['productDocId'] as List<dynamic>);
      return Ok(productIds);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }
}
