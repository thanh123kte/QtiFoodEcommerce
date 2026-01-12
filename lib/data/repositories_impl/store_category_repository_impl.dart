import 'package:dio/dio.dart';

import '../../domain/entities/create_store_category_input.dart';
import '../../domain/entities/store_category.dart';
import '../../domain/repositories/store_category_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/store_category_local.dart';
import '../datasources/remote/store_category_remote.dart';
import '../models/store_category_model.dart';

class StoreCategoryRepositoryImpl implements StoreCategoryRepository {
  final StoreCategoryRemote remote;
  final StoreCategoryLocal local;

  StoreCategoryRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<List<StoreCategory>>> getCategoriesByStore(int storeId) async {
    final cached = await local.getCategories(storeId);
    try {
      final jsonList = await remote.getByStore(storeId);
      final mapped = jsonList.map(StoreCategoryModel.fromJson).toList();
      await local.saveCategories(storeId, mapped);
      return Ok(mapped.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<StoreCategory>> createCategory(CreateStoreCategoryInput input) async {
    try {
      final json = await remote.create(input.toJson());
      final model = StoreCategoryModel.fromJson(json);
      await local.upsertCategory(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<StoreCategory>> updateCategory(
    int id,
    UpdateStoreCategoryInput input,
  ) async {
    try {
      final json = await remote.update(id, input.toJson());
      final model = StoreCategoryModel.fromJson(json);
      await local.upsertCategory(model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteCategory(int id) async {
    try {
      await remote.delete(id);
      await local.removeCategory(id);
      return const Ok(null);
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
