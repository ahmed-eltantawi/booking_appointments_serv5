import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_state.dart';

/// App-level cubit for managing theme mode and locale settings.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(const SettingsState(
          locale: Locale('en'),
          themeMode: ThemeMode.system,
        ));

  /// Switches the active application language locale.
  void setLocale(Locale locale) {
    if (state.locale == locale) return;
    emit(SettingsState(locale: locale, themeMode: state.themeMode));
  }

  /// Switches the active application theme mode.
  void setThemeMode(ThemeMode themeMode) {
    if (state.themeMode == themeMode) return;
    emit(SettingsState(locale: state.locale, themeMode: themeMode));
  }
}
