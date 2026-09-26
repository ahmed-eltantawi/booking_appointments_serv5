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

///* initialSchedule — the seed schedule loaded when the app starts or resets.
/// Contains a realistic mix of booked, unavailable, and available 30-minute slots.
///
/// Time slots (09:00 AM – 06:00 PM):
///   09:00 - 09:30 : Available
///   09:30 - 10:00 : Available
///   10:00 - 10:30 : Booked
///   10:30 - 11:00 : Booked
///   11:00 - 11:30 : Available
///   11:30 - 12:00 : Available
///   12:00 - 12:30 : Available
///   12:30 - 01:00 : Available
///   01:00 - 01:30 : Available
///   01:30 - 02:00 : Unavailable
///   02:00 - 02:30 : Available (gap trigger)
///   02:30 - 03:00 : Available (would be gap if 02:00 booked)
///   03:00 - 03:30 : Booked (gap anchor)
///   03:30 - 04:00 : Available
///   04:00 - 04:30 : Available
///   04:30 - 05:00 : Available
///   05:00 - 05:30 : Available
///   05:30 - 06:00 : Available
final List<TimeSlot> initialSchedule = [
  const TimeSlot(
    start: TimeOfDay(hour: 9, minute: 0),
    end: TimeOfDay(hour: 9, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 9, minute: 30),
    end: TimeOfDay(hour: 10, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 10, minute: 0),
    end: TimeOfDay(hour: 10, minute: 30),
    status: SlotStatus.booked,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 10, minute: 30),
    end: TimeOfDay(hour: 11, minute: 0),
    status: SlotStatus.booked,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 11, minute: 0),
    end: TimeOfDay(hour: 11, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 11, minute: 30),
    end: TimeOfDay(hour: 12, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 12, minute: 0),
    end: TimeOfDay(hour: 12, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 12, minute: 30),
    end: TimeOfDay(hour: 13, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 13, minute: 0),
    end: TimeOfDay(hour: 13, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 13, minute: 30),
    end: TimeOfDay(hour: 14, minute: 0),
    status: SlotStatus.unavailable,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 14, minute: 0),
    end: TimeOfDay(hour: 14, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 14, minute: 30),
    end: TimeOfDay(hour: 15, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 15, minute: 0),
    end: TimeOfDay(hour: 15, minute: 30),
    status: SlotStatus.booked,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 15, minute: 30),
    end: TimeOfDay(hour: 16, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 16, minute: 0),
    end: TimeOfDay(hour: 16, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 16, minute: 30),
    end: TimeOfDay(hour: 17, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 17, minute: 0),
    end: TimeOfDay(hour: 17, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 17, minute: 30),
    end: TimeOfDay(hour: 18, minute: 0),
    status: SlotStatus.available,
  ),
];
