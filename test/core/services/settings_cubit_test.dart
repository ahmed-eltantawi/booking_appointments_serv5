import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/cache/shared_preferences_helper.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences pref;
  late SharedPreferencesHelper helper;
  late SharedPreferencesService service;
  late SettingsCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pref = await SharedPreferences.getInstance();
    helper = SharedPreferencesHelper(pref);
    service = SharedPreferencesService(helper);
    cubit = SettingsCubit(service);
  });

  group('SettingsCubit Persistence Tests', () {
    test('initial state defaults to English and System theme if empty', () {
      expect(cubit.state.locale, equals(const Locale('en')));
      expect(cubit.state.themeMode, equals(ThemeMode.system));
    });

    test(
      'setting locale updates state and persists in SharedPreferences',
      () async {
        await cubit.setLocale(const Locale('ar'));

        expect(cubit.state.locale, equals(const Locale('ar')));
        expect(service.getLanguageCode(), equals('ar'));

        // Recreate cubit from same service to simulate app restart
        final newCubit = SettingsCubit(service);
        expect(newCubit.state.locale, equals(const Locale('ar')));
      },
    );

    test(
      'setting themeMode updates state and persists in SharedPreferences',
      () async {
        await cubit.setThemeMode(ThemeMode.dark);

        expect(cubit.state.themeMode, equals(ThemeMode.dark));
        expect(service.getThemeMode(), equals(ThemeMode.dark));

        // Recreate cubit from same service to simulate app restart
        final newCubit = SettingsCubit(service);
        expect(newCubit.state.themeMode, equals(ThemeMode.dark));
      },
    );
  });
}
