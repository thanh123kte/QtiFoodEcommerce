import 'package:dio/dio.dart';

class ShippingRemote {
  final Dio dio;

  ShippingRemote(this.dio);

  Future<Map<String, dynamic>> calculateFee({
    required double storeLat,
    required double storeLng,
    required double recipientLat,
    required double recipientLng,
  }) async {
    final res = await dio.post('/api/shipping/calculate-fee', data: {
      'storeLatitude': storeLat,
      'storeLongitude': storeLng,
      'recipientLatitude': recipientLat,
      'recipientLongitude': recipientLng,
    });
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return <String, dynamic>{};
  }
}
