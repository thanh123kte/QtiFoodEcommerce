import 'package:shared_preferences/shared_preferences.dart';

class SessionLocal {
  SessionLocal(this._prefs);

  final SharedPreferences _prefs;

  static const _rememberKey = 'remember_login';
  static const _lastEmailKey = 'last_login_email';
  static const _lastUserIdKey = 'last_user_id';
  static const _lastUserRoleKey = 'last_user_role';
  static const _lastFcmTokenKey = 'last_fcm_token';

  bool getRememberMe() => _prefs.getBool(_rememberKey) ?? false;

  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(_rememberKey, value);
  }

  String? getLastEmail() => _prefs.getString(_lastEmailKey);

  Future<void> setLastEmail(String email) async {
    await _prefs.setString(_lastEmailKey, email);
  }

  String? getLastUserId() => _prefs.getString(_lastUserIdKey);

  String? getLastUserRole() => _prefs.getString(_lastUserRoleKey);

  Future<void> saveLastUser({
    required String userId,
    required String role,
  }) async {
    await _prefs.setString(_lastUserIdKey, userId);
    await _prefs.setString(_lastUserRoleKey, role);
  }

  String? getLastFcmToken(String userId) {
    final raw = _prefs.getString(_lastFcmTokenKey);
    if (raw == null || raw.isEmpty) return null;
    final map = _decode(raw);
    return map[userId];
  }

  Future<void> saveLastFcmToken({
    required String userId,
    required String token,
  }) async {
    final raw = _prefs.getString(_lastFcmTokenKey);
    final map = raw == null || raw.isEmpty ? <String, String>{} : _decode(raw);
    map[userId] = token;
    await _prefs.setString(_lastFcmTokenKey, _encode(map));
  }

  Map<String, String> _decode(String value) {
    final result = <String, String>{};
    for (final pair in value.split('|')) {
      final parts = pair.split('::');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }
    return result;
  }

  String _encode(Map<String, String> map) => map.entries.map((e) => '${e.key}::${e.value}').join('|');
}
