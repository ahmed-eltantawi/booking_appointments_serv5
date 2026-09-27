import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/repo/booking_repository.dart';

/// This use case is used to reset the booking schedule.
/// It calls [BookingRepository.resetSchedule].
class ResetScheduleUseCase {
  const ResetScheduleUseCase({required this.bookingRepository});

  final BookingRepository bookingRepository;

  Future<Either<Failure, BookingSchedule>> call() async {
    return await bookingRepository.resetSchedule();
  }
}
