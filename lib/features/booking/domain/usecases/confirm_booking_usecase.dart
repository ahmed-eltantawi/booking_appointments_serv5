import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/repo/booking_repository.dart';

/// This use case is used to confirm a booking schedule.
/// It calls [BookingRepository.confirmBooking].
class ConfirmBookingUseCase {
  const ConfirmBookingUseCase({required this.bookingRepository});

  final BookingRepository bookingRepository;

  Future<Either<Failure, BookingSchedule>> call({
    required TimeOfDay startTime,
    required BookingDuration duration,
  }) async {
    return await bookingRepository.confirmBooking(
      startTime: startTime,
      duration: duration,
    );
  }
}
