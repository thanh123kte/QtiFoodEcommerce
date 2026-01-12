enum AddAddressSubmissionStatus { idle, submitting, success, failure }

class PlaceSuggestionViewData {
  final String id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;

  const PlaceSuggestionViewData({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
  });
}

