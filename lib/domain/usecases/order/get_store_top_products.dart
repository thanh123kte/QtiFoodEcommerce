import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/top_product_stat.dart';
import '../../repositories/order_repository.dart';

class GetStoreTopProducts {
  final OrderRepository _repository;

  GetStoreTopProducts(this._repository);

  Future<Result<List<TopProductStat>>> call(int storeId) {
    return _repository.getTopProducts(storeId: storeId);
  }
}
