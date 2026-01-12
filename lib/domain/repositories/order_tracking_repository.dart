import 'package:datn_foodecommerce_flutter_app/domain/entities/order_tracking.dart';

import '../../utils/result.dart';

abstract class OrderTrackingRepository {
  Stream<Result<OrderTracking>> getOrderTrackingStream(int orderId);
}
