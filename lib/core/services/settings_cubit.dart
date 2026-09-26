import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';

part 'settings_state.dart';

/// App-level cubit for managing theme mode and locale settings with persistence.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._sharedPreferencesService)
    : super(
        SettingsState(
          locale: Locale(_sharedPreferencesService.getLanguageCode()),
          themeMode: _sharedPreferencesService.getThemeMode(),
        ),
      );

  final SharedPreferencesService _sharedPreferencesService;

  /// Switches and persists the active application language locale.
  Future<void> setLocale(Locale locale) async {
    if (state.locale == locale) return;
    await _sharedPreferencesService.saveLanguageCode(locale.languageCode);
    emit(SettingsState(locale: locale, themeMode: state.themeMode));
  }

  /// Switches and persists the active application theme mode.
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state.themeMode == themeMode) return;
    await _sharedPreferencesService.saveThemeMode(themeMode);
    emit(SettingsState(locale: state.locale, themeMode: themeMode));
  }
}
