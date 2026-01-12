// const String kServerBaseUrl = 'http://10.0.2.2:8080/';
// const String kServerBaseUrl = 'http://localhost:8080/';
// const String kServerBaseUrl = 'https://inconceivably-octantal-chan.ngrok-free.dev/';
// const String kServerBaseUrl = 'https://e31fa25e0f4c.ngrok-free.app/'; alienn
const String kServerBaseUrl = 'https://inconceivably-octantal-chan.ngrok-free.dev/';
String get _normalizedServerBaseUrl {
  if (kServerBaseUrl.isEmpty) {
    throw StateError('kServerBaseUrl must not be empty');
  }
  return kServerBaseUrl.endsWith('/') ? kServerBaseUrl.substring(0, kServerBaseUrl.length - 1) : kServerBaseUrl;
}

/// Resolves relative asset paths returned by the API into absolute URLs consumable by Image.network.
String? resolveServerAssetUrl(String? rawPath) {
  if (rawPath == null) return null;
  final value = rawPath.trim();
  if (value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final sanitizedPath = value.startsWith('/') ? value.substring(1) : value;
  if (sanitizedPath.isEmpty) return _normalizedServerBaseUrl;
  return '$_normalizedServerBaseUrl/$sanitizedPath';
}
