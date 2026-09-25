import 'package:booking_appointments/core/errors/either.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';

/// Repository contract for appointment booking business and data operations.
abstract class BookingRepository {
  /// Loads or retrieves the current schedule state.
  Future<Either<Failure, BookingSchedule>> getSchedule();

  /// Changes the active booking duration and recalculates valid start times.
  Future<Either<Failure, BookingSchedule>> selectDuration(
    BookingDuration duration,
    int? currentStartIndex,
  );

  /// Selects a start time slot and validates the selection.
  Future<Either<Failure, BookingSchedule>> selectStartTime(
    int slotIndex,
    BookingDuration duration,
  );

  /// Confirms the current booking, updating the schedule data if valid.
  Future<Either<Failure, BookingSchedule>> confirmBooking({
    required int startIndex,
    required BookingDuration duration,
  });

  /// Resets the schedule back to the original seed data.
  Future<Either<Failure, BookingSchedule>> resetSchedule();
}
