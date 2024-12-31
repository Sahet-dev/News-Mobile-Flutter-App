import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _lastUpdatedKey = 'last_updated';

  Future<void> saveLastUpdated(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdatedKey, timestamp);
  }

  Future<String?> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdatedKey);
  }
}
