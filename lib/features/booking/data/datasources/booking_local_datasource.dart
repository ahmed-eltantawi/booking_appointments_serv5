import 'package:flutter/material.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// Contract for local schedule persistence and user identity access.
abstract class BookingLocalDataSource {
  /// Retrieves or initializes a stable local user ID.
  String getCurrentUserId();

  /// Retrieves the schedule with persisted user bookings applied.
  Future<List<TimeSlot>> getSchedule({required String currentUserId});

  /// Saves a newly confirmed user booking locally.
  Future<void> saveUserBooking({
    required TimeOfDay startTime,
    required BookingDuration duration,
    required String currentUserId,
  });

  /// Clears all local user bookings.
  Future<void> clearUserBookings();
}
