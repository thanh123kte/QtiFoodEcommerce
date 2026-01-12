import 'package:dio/dio.dart';

import '../../domain/entities/shipping_fee.dart';
import '../../domain/repositories/shipping_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/shipping_remote.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingRemote remote;

  ShippingRepositoryImpl(this.remote);

  @override
  Future<Result<ShippingFee>> calculateFee({
    required double storeLat,
    required double storeLng,
    required double recipientLat,
    required double recipientLng,
  }) async {
    try {
      final json = await remote.calculateFee(
        storeLat: storeLat,
        storeLng: storeLng,
        recipientLat: recipientLat,
        recipientLng: recipientLng,
      );
      return Ok(_map(json));
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  ShippingFee _map(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return ShippingFee(
      distanceKm: parseDouble(json['distanceKm']),
      baseFee: parseDouble(json['baseFee']),
      additionalFee: parseDouble(json['additionalFee']),
      totalFee: parseDouble(json['totalFee']),
      description: json['description']?.toString(),
    );
  }
}
