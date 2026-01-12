import 'package:datn_foodecommerce_flutter_app/config/server_config.dart';

String? resolveImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  final base = kServerBaseUrl.endsWith('/') ? kServerBaseUrl.substring(0, kServerBaseUrl.length - 1) : kServerBaseUrl;
  final path = raw.startsWith('/') ? raw : '/$raw';
  return '$base$path';
}