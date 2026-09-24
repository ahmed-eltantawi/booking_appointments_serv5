import 'package:get_it/get_it.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  //! ========= Services =========
  getIt.registerLazySingleton<SettingsCubit>(SettingsCubit.new);

  //! ========= Features =========
  getIt.registerFactory<BookingCubit>(BookingCubit.new);
}
