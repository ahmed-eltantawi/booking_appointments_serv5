import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';

/// Repository contract for appointment booking business and data operations.
abstract class BookingRepository {
  /// Loads or retrieves the current schedule state.
  Future<Either<Failure, BookingSchedule>> getSchedule();

  /// Changes the active booking duration and recalculates valid start times.
  /// Preserves currentStart and revalidates it if non-null (ISSUE-002).
  Future<Either<Failure, BookingSchedule>> selectDuration(
    BookingDuration duration,
    TimeOfDay? currentStart,
  );

  /// Selects a start time slot and validates the selection.
  Future<Either<Failure, BookingSchedule>> selectStartTime(
    TimeOfDay startTime,
    BookingDuration duration,
  );

  /// Confirms the current booking, updating the schedule data if valid.
  Future<Either<Failure, BookingSchedule>> confirmBooking({
    required TimeOfDay startTime,
    required BookingDuration duration,
  });

  /// Resets the schedule back to the original seed data.
  Future<Either<Failure, BookingSchedule>> resetSchedule();
}
