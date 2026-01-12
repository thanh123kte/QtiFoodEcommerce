class NearbyStore {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final double distanceKm;
  final String? imageUrl;

  const NearbyStore({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.imageUrl,
  });
}
