import 'package:datn_foodecommerce_flutter_app/domain/entities/order_tracking.dart';
import 'package:datn_foodecommerce_flutter_app/domain/repositories/order_tracking_repository.dart';
import 'package:datn_foodecommerce_flutter_app/utils/result.dart';


class GetOrderTrackingStream {
  final OrderTrackingRepository _repository;

  GetOrderTrackingStream(this._repository);

  Stream<Result<OrderTracking>> call(int orderId) {
    return _repository.getOrderTrackingStream(orderId);
  }
}
