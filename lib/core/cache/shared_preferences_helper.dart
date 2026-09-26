import 'package:shared_preferences/shared_preferences.dart';

/// Low-level wrapper around [SharedPreferences] for basic type storage.
class SharedPreferencesHelper {
  const SharedPreferencesHelper(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  /// Saves dynamic primitive values (String, int, double, bool).
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) {
      return await _sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await _sharedPreferences.setInt(key, value);
    } else if (value is double) {
      return await _sharedPreferences.setDouble(key, value);
    } else if (value is bool) {
      return await _sharedPreferences.setBool(key, value);
    } else {
      return false;
    }
  }

  /// Retrieves data stored at [key].
  dynamic getData({required String key}) {
    return _sharedPreferences.get(key);
  }

  /// Removes data stored at [key].
  Future<bool> removeData({required String key}) async {
    return await _sharedPreferences.remove(key);
  }

  /// Clears all keys in SharedPreferences.
  Future<bool> clearData() async {
    return await _sharedPreferences.clear();
  }
}
