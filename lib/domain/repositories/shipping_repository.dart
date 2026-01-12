import '../../utils/result.dart';
import '../entities/shipping_fee.dart';

abstract class ShippingRepository {
  Future<Result<ShippingFee>> calculateFee({
    required double storeLat,
    required double storeLng,
    required double recipientLat,
    required double recipientLng,
  });
}
