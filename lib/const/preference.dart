import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static SharedPreferences _preferences = _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static void setStringIfNotNull(String key, String? value) {
    if (value != null)
      SharedPreferences.getInstance()
          .then((prefs) => prefs.setString(key, value));
  }

  static void setIntIfNotNull(String key, int? value) {
    if (value != null)
      SharedPreferences.getInstance().then((prefs) => prefs.setInt(key, value));
  }

  static Future setString(String key, String value) async =>
      await _preferences.setString(key, value);

  static Future setDouble(String key, double value) async =>
      await _preferences.setDouble(key, value);

  static String? getString(String key) => _preferences.getString(key) ?? "";

  static double? getDouble(String key) => _preferences.getDouble(key);

  static Future setBoolean(String key, bool value) async =>
      await _preferences.setBool(key, value);

  static bool getBoolean(String key) => _preferences.getBool(key) ?? false;

  static int? getInt(dynamic key) {
    return _preferences.getInt("$key");
  }

  static Future setInt(String key, int value) async {
    return await _preferences.setInt("$key", value);
  }

  static void clearPref() {
    _preferences.clear();
  }
}
