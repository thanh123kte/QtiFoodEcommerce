import '../../utils/result.dart';
import '../entities/banner.dart';

abstract class BannerRepository {
  Future<Result<List<BannerEntity>>> getBannersByStatus(String status);
}
