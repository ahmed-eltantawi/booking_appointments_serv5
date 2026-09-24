import 'package:get_it/get_it.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  //! ========= Features =========
  //TODO: Put here all your features

  // ---> Booking <---
  getIt.registerFactory<BookingCubit>(BookingCubit.new);
}
