import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/cache/shared_preferences_helper.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:booking_appointments/features/booking/data/datasources/booking_local_datasource_impl.dart';
import 'package:booking_appointments/features/booking/data/repo/booking_repository_impl.dart';
import 'package:booking_appointments/features/booking/domain/repo/booking_repository.dart';
import 'package:booking_appointments/features/booking/domain/usecases/confirm_booking_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/get_schedule_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/reset_schedule_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/select_duration_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/select_start_time_usecase.dart';
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

  //! ========= Data Sources =========
  getIt.registerLazySingleton<BookingLocalDataSource>(
    () => BookingLocalDataSourceImpl(getIt()),
  );

  //! ========= Services =========
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit(getIt()));

  //! ========= Repositories =========
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(getIt()),
  );

  //! ========= Use Cases =========
  getIt.registerLazySingleton<GetScheduleUseCase>(
    () => GetScheduleUseCase(bookingRepository: getIt()),
  );
  getIt.registerLazySingleton<SelectDurationUseCase>(
    () => SelectDurationUseCase(bookingRepository: getIt()),
  );
  getIt.registerLazySingleton<SelectStartTimeUseCase>(
    () => SelectStartTimeUseCase(bookingRepository: getIt()),
  );
  getIt.registerLazySingleton<ConfirmBookingUseCase>(
    () => ConfirmBookingUseCase(bookingRepository: getIt()),
  );
  getIt.registerLazySingleton<ResetScheduleUseCase>(
    () => ResetScheduleUseCase(bookingRepository: getIt()),
  );

  //! ========= Features =========
  getIt.registerFactory<BookingCubit>(
    () => BookingCubit(
      getScheduleUseCase: getIt(),
      selectDurationUseCase: getIt(),
      selectStartTimeUseCase: getIt(),
      confirmBookingUseCase: getIt(),
      resetScheduleUseCase: getIt(),
    ),
  );
}
