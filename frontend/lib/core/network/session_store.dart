import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class SessionStore {
  SessionStore({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  static const String _userKey = 'pathseek.currentUser';

  final TokenStorage _tokenStorage;

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userJson,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userJson);
  }

  Future<String?> readUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<String?> readRefreshToken() => _tokenStorage.readRefreshToken();

  Future<void> clear() async {
    await _tokenStorage.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
