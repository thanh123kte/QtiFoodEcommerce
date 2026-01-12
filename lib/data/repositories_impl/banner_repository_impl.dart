import 'package:dio/dio.dart';

import '../../domain/entities/banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/banner_remote.dart';
import '../models/banner_model.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemote remote;

  BannerRepositoryImpl(this.remote);

  @override
  Future<Result<List<BannerEntity>>> getBannersByStatus(String status) async {
    try {
      final jsonList = await remote.getByStatus(status);
      final banners = jsonList.map(BannerModel.fromJson).map((e) => e.toEntity()).toList();
      return Ok(banners);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
