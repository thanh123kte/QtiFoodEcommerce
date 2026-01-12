import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/banner.dart';
import '../../repositories/banner_repository.dart';

class GetBannersByStatus {
  final BannerRepository repository;

  GetBannersByStatus(this.repository);

  Future<Result<List<BannerEntity>>> call(String status) {
    return repository.getBannersByStatus(status);
  }
}
