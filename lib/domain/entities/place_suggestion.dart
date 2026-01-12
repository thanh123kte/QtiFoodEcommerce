class PlaceSuggestion {
  final String id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;

  const PlaceSuggestion({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
  });
}

