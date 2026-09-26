import 'package:flutter/material.dart';
import 'package:booking_appointments/core/cache/cache_key.dart';
import 'package:booking_appointments/core/cache/shared_preferences_helper.dart';

/// Semantic caching service for app settings and user preferences.
class SharedPreferencesService {
  const SharedPreferencesService(this._sharedPreferencesHelper);

  final SharedPreferencesHelper _sharedPreferencesHelper;

  /// Saves active [ThemeMode] enum preference.
  Future<bool> saveThemeMode(ThemeMode themeMode) async {
    return await _sharedPreferencesHelper.saveData(
      key: CacheKey.themeMode,
      value: themeMode.name,
    );
  }

  /// Retrieves saved [ThemeMode] preference. Defaults to [ThemeMode.system].
  ThemeMode getThemeMode() {
    final String? modeName =
        _sharedPreferencesHelper.getData(key: CacheKey.themeMode) as String?;

    if (modeName == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (element) => element.name == modeName,
      orElse: () => ThemeMode.system,
    );
  }

  /// Saves active language code preference (e.g. 'en', 'ar').
  Future<bool> saveLanguageCode(String languageCode) async {
    return await _sharedPreferencesHelper.saveData(
      key: CacheKey.languageCode,
      value: languageCode,
    );
  }

  /// Retrieves saved language code. Defaults to 'en'.
  String getLanguageCode() {
    final String? code =
        _sharedPreferencesHelper.getData(key: CacheKey.languageCode) as String?;

    return code ?? 'en';
  }

  /// Retrieves or generates a persistent, stable [currentUserId].
  String getOrCreateCurrentUserId() {
    final String? existingId = _sharedPreferencesHelper.getData(
      key: CacheKey.currentUserId,
    ) as String?;

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _sharedPreferencesHelper.saveData(
      key: CacheKey.currentUserId,
      value: newId,
    );
    return newId;
  }

  /// Saves the user's booking data serialized as a JSON string.
  Future<bool> saveUserBookingsJson(String jsonString) async {
    return await _sharedPreferencesHelper.saveData(
      key: CacheKey.userBookings,
      value: jsonString,
    );
  }

  /// Retrieves stored user's booking data as a JSON string.
  String? getUserBookingsJson() {
    return _sharedPreferencesHelper.getData(key: CacheKey.userBookings)
        as String?;
  }

  /// Clears stored user's booking data.
  Future<bool> clearUserBookingsJson() async {
    return await _sharedPreferencesHelper.removeData(
      key: CacheKey.userBookings,
    );
  }
}
