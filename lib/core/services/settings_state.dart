part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
    required this.themeMode,
  });

  final Locale locale;
  final ThemeMode themeMode;

  @override
  List<Object?> get props => [locale, themeMode];
}
