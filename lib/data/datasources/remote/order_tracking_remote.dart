import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/order_tracking.dart';

class OrderTrackingRemote {
  final FirebaseDatabase _database;
  static const String _trackingPath = 'order_tracking';

  OrderTrackingRemote(this._database);

  Stream<OrderTracking> getTrackingStream(int orderId) {
    if (kDebugMode) {
      debugPrint('[OrderTrackingRemote] Starting getTrackingStream for orderId: $orderId');
      debugPrint('[OrderTrackingRemote] Firebase RTDB path: $_trackingPath/$orderId');
    }
    
    final ref = _database.ref().child(_trackingPath).child(orderId.toString());
    
    return ref.onValue.map((event) {
      if (kDebugMode) {
        debugPrint('[OrderTrackingRemote] Received onValue event for orderId: $orderId');
        debugPrint('[OrderTrackingRemote] Raw snapshot value: ${event.snapshot.value}');
        debugPrint('[OrderTrackingRemote] Snapshot key: ${event.snapshot.key}');
        debugPrint('[OrderTrackingRemote] Snapshot exists: ${event.snapshot.exists}');
      }
      
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        if (kDebugMode) {
          debugPrint('[OrderTrackingRemote] ERROR: Data is null for orderId: $orderId');
        }
        throw Exception('Tracking data not found');
      }
      
      if (kDebugMode) {
        debugPrint('[OrderTrackingRemote] Parsing data: $data');
      }
      
      final tracking = _parseOrderTracking(data);
      
      if (kDebugMode) {
        debugPrint('[OrderTrackingRemote] Successfully parsed tracking:');
        debugPrint('[OrderTrackingRemote] - Driver: ${tracking.driverName} (${tracking.driverId})');
        debugPrint('[OrderTrackingRemote] - Location: (${tracking.driverLocation.latitude}, ${tracking.driverLocation.longitude})');
        debugPrint('[OrderTrackingRemote] - Status: ${tracking.status}');
        debugPrint('[OrderTrackingRemote] - Updated at: ${tracking.driverLocation.updatedAt}');
      }
      
      return tracking;
    }).handleError((error) {
      if (kDebugMode) {
        debugPrint('[OrderTrackingRemote] ERROR in stream: $error');
        debugPrint('[OrderTrackingRemote] Error stacktrace: ${StackTrace.current}');
      }
      throw error;
    });
  }

  OrderTracking _parseOrderTracking(Map<dynamic, dynamic> data) {
    if (kDebugMode) {
      debugPrint('[OrderTrackingRemote._parseOrderTracking] Starting parse');
    }
    
    final driverLocData = data['driverLocation'] as Map<dynamic, dynamic>?;
    if (kDebugMode) {
      debugPrint('[OrderTrackingRemote._parseOrderTracking] driverLocation data: $driverLocData');
    }
    
    final num driverLatNum = (driverLocData?['latitude'] ?? 0) as num;
    final num driverLngNum = (driverLocData?['longitude'] ?? 0) as num;
    final driverLat = driverLatNum.toDouble();
    final driverLng = driverLngNum.toDouble();
    final updatedRaw = driverLocData?['updatedAt'];
    late DateTime driverUpdatedAt;
    if (updatedRaw is int) {
      driverUpdatedAt = DateTime.fromMillisecondsSinceEpoch(updatedRaw);
    } else if (updatedRaw is String) {
      driverUpdatedAt = DateTime.tryParse(updatedRaw) ?? DateTime.now();
    } else {
      driverUpdatedAt = DateTime.now();
    }

    if (kDebugMode) {
      debugPrint('[OrderTrackingRemote._parseOrderTracking] Extracted coordinates: ($driverLat, $driverLng)');
      debugPrint('[OrderTrackingRemote._parseOrderTracking] Updated timestamp: $driverUpdatedAt');
    }

    return OrderTracking(
      orderId: (data['orderId'] ?? 0) as int,
      driverId: (data['driverId'] ?? '') as String,
      driverName: (data['driverName'] ?? '') as String,
      driverPhone: (data['driverPhone'] ?? '') as String,
      driverLocation: DriverLocation(
        latitude: driverLat,
        longitude: driverLng,
        updatedAt: driverUpdatedAt,
      ),
      recipientLatitude: (data['shippingLatitude'] as num?)?.toDouble(),
      recipientLongitude: (data['shippingLongitude'] as num?)?.toDouble(),
      shippingAddress: (data['shippingAddress'] ?? '') as String,
      storeAddress: (data['storeAddress'] ?? '') as String,
      status: (data['status'] ?? 'SHIPPING') as String,
      assignedAt: DateTime.parse((data['assignedAt'] ?? '') as String? ?? '2025-01-01T00:00:00'),
    );
  }
}
