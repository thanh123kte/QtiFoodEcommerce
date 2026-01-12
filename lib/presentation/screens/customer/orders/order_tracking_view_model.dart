import 'dart:async';
import 'package:datn_foodecommerce_flutter_app/domain/entities/order_tracking.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/order/get_order_tracking_stream.dart';
import 'package:datn_foodecommerce_flutter_app/utils/result.dart';
import 'package:flutter/material.dart';


class OrderTrackingViewModel extends ChangeNotifier {
  final GetOrderTrackingStream _getOrderTrackingStream;

  OrderTracking? _tracking;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Result<OrderTracking>>? _subscription;

  OrderTracking? get tracking => _tracking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderTrackingViewModel(this._getOrderTrackingStream);

  Future<void> startTracking(int orderId) async {
    debugPrint('[OrderTrackingViewModel] startTracking called with orderId: $orderId');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    debugPrint('[OrderTrackingViewModel] Creating stream subscription');
    
    _subscription = _getOrderTrackingStream(orderId).listen(
      (result) {
        debugPrint('[OrderTrackingViewModel] Received result from stream');
        result.when(
          ok: (tracking) {
            debugPrint('[OrderTrackingViewModel] Result is OK');
            debugPrint('[OrderTrackingViewModel] Driver: ${tracking.driverName}');
            debugPrint('[OrderTrackingViewModel] Location: (${tracking.driverLocation.latitude}, ${tracking.driverLocation.longitude})');
            
            _tracking = tracking;
            _error = null;
            _isLoading = false;
            notifyListeners();
            
            debugPrint('[OrderTrackingViewModel] Updated UI state');
          },
          err: (message) {
            debugPrint('[OrderTrackingViewModel] Result is ERROR: $message');
            _error = message;
            _isLoading = false;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        debugPrint('[OrderTrackingViewModel] Stream error: $error');
        debugPrint('[OrderTrackingViewModel] Error type: ${error.runtimeType}');
        _error = 'Error listening to tracking updates: ${error.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );
    
    debugPrint('[OrderTrackingViewModel] Subscription created and listening');
  }

  void stopTracking() {
    debugPrint('[OrderTrackingViewModel] stopTracking called');
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    debugPrint('[OrderTrackingViewModel] dispose called');
    stopTracking();
    super.dispose();
  }
}
