import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/cache/shared_preferences_helper.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/features/booking/data/booking_repository_impl.dart';
import 'package:booking_appointments/features/booking/domain/booking_repository.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  //! ========= External =========
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  //! ========= Core Storage Helpers =========
  getIt.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(getIt()),
  );

  //! ========= Core Services =========
  getIt.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(getIt()),
  );

  //! ========= Services =========
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(getIt()),
  );

  //! ========= Repositories =========
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(),
  );

  //! ========= Features =========
  getIt.registerFactory<BookingCubit>(
    () => BookingCubit(getIt()),
  );
}
