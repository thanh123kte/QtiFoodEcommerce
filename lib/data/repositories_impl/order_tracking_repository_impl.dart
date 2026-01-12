import 'package:datn_foodecommerce_flutter_app/data/datasources/remote/order_tracking_remote.dart';
import 'package:datn_foodecommerce_flutter_app/utils/result.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/order_tracking.dart';
import '../../../domain/repositories/order_tracking_repository.dart';


class OrderTrackingRepositoryImpl extends OrderTrackingRepository {
  final OrderTrackingRemote _remote;

  OrderTrackingRepositoryImpl(this._remote);

  @override
  Stream<Result<OrderTracking>> getOrderTrackingStream(int orderId) {
    if (kDebugMode) {
      debugPrint('[OrderTrackingRepositoryImpl] getOrderTrackingStream called for orderId: $orderId');
    }
    
    return _remote.getTrackingStream(orderId).map((tracking) {
      if (kDebugMode) {
        debugPrint('[OrderTrackingRepositoryImpl] Mapping tracking to Ok result');
      }
      return Ok<OrderTracking>(tracking);
    }).handleError((error) {
      if (kDebugMode) {
        debugPrint('[OrderTrackingRepositoryImpl] ERROR: $error');
        debugPrint('[OrderTrackingRepositoryImpl] Mapping to Err result');
      }
      return Err<OrderTracking>(error.toString());
    });
  }
}
