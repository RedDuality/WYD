import 'package:shared_preferences/shared_preferences.dart';

class UriService {
  static const _uriKey = 'current_uri';

  /// Saves the URI to persistent storage
  static Future<void> saveUri(String uri) async {
    if (uri != '/login' && uri != '/') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_uriKey, uri);
    }
  }

  /// Retrieves the saved URI, defaults to "/"
  static Future<String> getUri() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uriKey) ?? "/";
  }
}

