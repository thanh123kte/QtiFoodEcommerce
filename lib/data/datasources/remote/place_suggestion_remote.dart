import 'package:dio/dio.dart';

import '../../../services/location/location_provider.dart';

class PlaceSuggestionRemote {
  final Dio dio;
  final LocationProvider locationProvider;
  final String apiKey;
  final String baseUrl;
  final String language;

  PlaceSuggestionRemote(
    this.dio,
    this.locationProvider, {
    required this.apiKey,
    this.baseUrl = 'https://autosuggest.search.hereapi.com',
    this.language = 'vi',
  });

  Future<List<Map<String, dynamic>>> fetchSuggestions({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const [];
    }

    final parameters = <String, String>{
      'q': trimmedQuery,
      'apiKey': apiKey,
      'limit': limit.toString(),
      'lang': language,
    };

    double? lat = latitude;
    double? lng = longitude;

    if (!_isValidCoordinate(lat, lng)) {
      try {
        final location = await locationProvider.getCurrentPosition();
        lat = location.latitude;
        lng = location.longitude;
      } on LocationException catch (error) {
        throw StateError(error.message);
      } catch (error) {
        throw StateError('Unable to determine device location: $error');
      }
    }

    if (!_isValidCoordinate(lat, lng)) {
      throw StateError(
        'Latitude and longitude are required to search for address suggestions.',
      );
    }

    parameters['at'] =
        '${lat!.toStringAsFixed(6)},${lng!.toStringAsFixed(6)}';

    final targetUri = _buildUri(parameters);
    final response = await dio.getUri(targetUri);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  bool _isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (latitude == 0 && longitude == 0) return false;
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Uri _buildUri(Map<String, String> parameters) {
    var parsedBase = Uri.parse(baseUrl);
    if (parsedBase.host.isEmpty && parsedBase.path.isNotEmpty) {
      parsedBase = Uri.parse('https://${parsedBase.path}');
    }

    final segments = List<String>.from(
      parsedBase.pathSegments.where((segment) => segment.isNotEmpty),
    );

    final hasAutosuggestSuffix = segments.length >= 2 &&
        segments[segments.length - 2] == 'v1' &&
        segments.last == 'autosuggest';

    if (!hasAutosuggestSuffix) {
      segments
        ..add('v1')
        ..add('autosuggest');
    }

    return Uri(
      scheme: parsedBase.scheme.isNotEmpty ? parsedBase.scheme : 'https',
      host: parsedBase.host,
      port: parsedBase.hasPort ? parsedBase.port : null,
      pathSegments: segments,
      queryParameters: parameters,
    );
  }
}
