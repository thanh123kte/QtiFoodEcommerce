import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/shipping_fee.dart';
import '../../repositories/shipping_repository.dart';

class CalculateShippingFee {
  final ShippingRepository repository;

  CalculateShippingFee(this.repository);

  Future<Result<ShippingFee>> call({
    required double storeLat,
    required double storeLng,
    required double recipientLat,
    required double recipientLng,
  }) {
    return repository.calculateFee(
      storeLat: storeLat,
      storeLng: storeLng,
      recipientLat: recipientLat,
      recipientLng: recipientLng,
    );
  }
}
