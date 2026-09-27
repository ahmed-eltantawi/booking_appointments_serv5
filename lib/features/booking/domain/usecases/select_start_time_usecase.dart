import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/repo/booking_repository.dart';

/// This use case is used to select a booking start time.
/// It calls [BookingRepository.selectStartTime].
class SelectStartTimeUseCase {
  const SelectStartTimeUseCase({required this.bookingRepository});

  final BookingRepository bookingRepository;

  Future<Either<Failure, BookingSchedule>> call(
    TimeOfDay startTime,
    BookingDuration duration, {
    TimeOfDay? currentStart,
  }) async {
    return await bookingRepository.selectStartTime(
      startTime,
      duration,
      currentStart: currentStart,
    );
  }
}
