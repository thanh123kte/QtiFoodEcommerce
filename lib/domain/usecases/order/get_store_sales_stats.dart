import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/sales_stats.dart';
import '../../repositories/order_repository.dart';

class GetStoreSalesStats {
  final OrderRepository _repository;
  GetStoreSalesStats(this._repository);

  Future<Result<SalesStats>> call({
    required int storeId,
    required String period,
  }) {
    return _repository.getSalesStats(storeId: storeId, period: period);
  }
}
