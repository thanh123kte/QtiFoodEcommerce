class ShippingFee {
  final double distanceKm;
  final double baseFee;
  final double additionalFee;
  final double totalFee;
  final String? description;

  const ShippingFee({
    required this.distanceKm,
    required this.baseFee,
    required this.additionalFee,
    required this.totalFee,
    this.description,
  });
}
