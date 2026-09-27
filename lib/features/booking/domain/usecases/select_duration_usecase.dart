import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/repo/booking_repository.dart';

/// This use case is used to select a booking duration.
/// It calls [BookingRepository.selectDuration].
class SelectDurationUseCase {
  const SelectDurationUseCase({required this.bookingRepository});

  final BookingRepository bookingRepository;

  Future<Either<Failure, BookingSchedule>> call(
    BookingDuration duration,
    TimeOfDay? currentStart,
  ) async {
    return await bookingRepository.selectDuration(duration, currentStart);
  }
}
