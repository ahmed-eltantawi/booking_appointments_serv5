import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/repo/booking_repository.dart';

/// This use case is used to get the booking schedule.
/// It calls [BookingRepository.getSchedule].
class GetScheduleUseCase {
  const GetScheduleUseCase({required this.bookingRepository});

  final BookingRepository bookingRepository;

  Future<Either<Failure, BookingSchedule>> call() async {
    return await bookingRepository.getSchedule();
  }
}
