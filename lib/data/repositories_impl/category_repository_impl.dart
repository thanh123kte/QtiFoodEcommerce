import 'package:dio/dio.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/category_local.dart';
import '../datasources/remote/category_remote.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemote remote;
  final CategoryLocal local;

  CategoryRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<List<FatherCategory>>> getCategories() async {
    final cached = await local.getCategories();
    try {
      final list = await remote.getCategories();
      final mapped = list.map(CategoryModel.fromJson).toList();
      await local.saveCategories(mapped);
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

  String _readMessage(DioException exception) {
    return exception.response?.data?.toString() ?? exception.message ?? 'API error';
  }
}
