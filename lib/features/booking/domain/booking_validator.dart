import 'package:flutter/material.dart';
import 'package:booking_appointments/features/booking/data/local_schedule.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/time_slot.dart';

/// Core domain service for appointment scheduling and validation rules.
///
/// Encapsulates all business logic for slot availability, working hours,
/// conflict detection, and gap detection without Flutter UI dependencies.
class BookingValidator {
  const BookingValidator();

  /// Calculates the inclusive/exclusive end time for a booking starting at
  /// [startTime] with the specified [duration].
  static TimeOfDay calculateEndTime(TimeOfDay startTime, BookingDuration duration) {
    final totalMinutes = startTime.hour * 60 + startTime.minute + duration.minutes;
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Checks if a booking from [startTime] for [duration] is within working day boundaries.
  static bool isWithinWorkingHours({
    required TimeOfDay startTime,
    required BookingDuration duration,
    TimeOfDay dayEndTime = kDayEndTime,
  }) {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = startMins + duration.minutes;
    final dayStartMins = kDayStartTime.hour * 60 + kDayStartTime.minute;
    final dayEndMins = dayEndTime.hour * 60 + dayEndTime.minute;
    return startMins >= dayStartMins && endMins <= dayEndMins;
  }

  /// Returns the list of time slots required for a booking starting at [startTime]
  /// for [duration] from [schedule].
  List<TimeSlot> getRequiredSlots({
    required List<TimeSlot> schedule,
    required TimeOfDay startTime,
    required BookingDuration duration,
  }) {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = startMins + duration.minutes;
    return schedule.where((slot) {
      final slotStartMins = slot.startMinutes;
      return slotStartMins >= startMins && slotStartMins < endMins;
    }).toList();
  }

  /// Detects all isolated free 30-minute gaps in [slots].
  ///
  /// An isolated gap is an available slot surrounded on BOTH sides by an occupied
  /// slot (booked or unavailable). Edge slots (first and last slot of schedule)
  /// are not considered isolated gaps as they have only one neighbor.
  Set<TimeOfDay> getIsolatedGapStartTimes(List<TimeSlot> slots) {
    final gaps = <TimeOfDay>{};
    if (slots.length < 3) return gaps;

    for (var i = 1; i < slots.length - 1; i++) {
      final current = slots[i];
      if (current.status != SlotStatus.available) continue;

      final prev = slots[i - 1];
      final next = slots[i + 1];

      final isPrevOccupied =
          prev.status == SlotStatus.booked || prev.status == SlotStatus.unavailable;
      final isNextOccupied =
          next.status == SlotStatus.booked || next.status == SlotStatus.unavailable;

      if (isPrevOccupied && isNextOccupied) {
        gaps.add(current.start);
      }
    }
    return gaps;
  }

  /// Returns all valid start times in [schedule] for [duration].
  List<TimeOfDay> getValidStartTimes({
    required List<TimeSlot> schedule,
    required BookingDuration duration,
    TimeOfDay dayEndTime = kDayEndTime,
  }) {
    final validStarts = <TimeOfDay>[];
    for (final slot in schedule) {
      if (slot.status != SlotStatus.available) continue;
      final result = validateBooking(
        schedule: schedule,
        startTime: slot.start,
        duration: duration,
        dayEndTime: dayEndTime,
      );
      if (result.isValid) {
        validStarts.add(slot.start);
      }
    }
    return validStarts;
  }

  /// Validates a booking attempt against [schedule].
  ///
  /// Evaluated rules in priority order:
  ///   1. Invalid input / nonexistent start time (ISSUE-014)
  ///   2. Working-hours boundary check (exceeds 6:00 PM)
  ///   3. Booked slot collision
  ///   4. Unavailable slot collision
  ///   5. Isolated gap creation check (comparing gaps before vs after booking) (ISSUE-001)
  BookingValidationResult validateBooking({
    required List<TimeSlot> schedule,
    required TimeOfDay? startTime,
    required BookingDuration duration,
    TimeOfDay dayEndTime = kDayEndTime,
  }) {
    // --- Rule 1: Null or out-of-range input protection ---
    if (startTime == null) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.exceedsWorkingHours,
      );
    }

    final startMins = startTime.hour * 60 + startTime.minute;
    final dayStartMins = kDayStartTime.hour * 60 + kDayStartTime.minute;
    final dayEndMins = dayEndTime.hour * 60 + dayEndTime.minute;

    if (startMins < dayStartMins || startMins >= dayEndMins) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.exceedsWorkingHours,
      );
    }

    // --- Rule 2: Working hours check ---
    final endMins = startMins + duration.minutes;
    if (endMins > dayEndMins) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.exceedsWorkingHours,
      );
    }

    // --- Rule 3 & 4: Required slots conflict checks ---
    final requiredSlots = getRequiredSlots(
      schedule: schedule,
      startTime: startTime,
      duration: duration,
    );

    if (requiredSlots.length < duration.slotCount) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.exceedsWorkingHours,
      );
    }

    final bookedSlots =
        requiredSlots.where((s) => s.status == SlotStatus.booked).toList();
    if (bookedSlots.isNotEmpty) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.containsBookedSlot,
      );
    }

    final unavailableSlots =
        requiredSlots.where((s) => s.status == SlotStatus.unavailable).toList();
    if (unavailableSlots.isNotEmpty) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.containsUnavailableSlot,
      );
    }

    // --- Rule 5: Gap rule — reject ONLY newly created isolated gaps (ISSUE-001) ---
    final isolatedBefore = getIsolatedGapStartTimes(schedule);
    final simulatedSchedule = applyBooking(
      schedule: schedule,
      startTime: startTime,
      duration: duration,
    );
    final isolatedAfter = getIsolatedGapStartTimes(simulatedSchedule);

    final newlyCreatedGaps =
        isolatedAfter.where((gapTime) => !isolatedBefore.contains(gapTime));
    if (newlyCreatedGaps.isNotEmpty) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.createsInvalidGap,
      );
    }

    return const BookingValidationResult.valid();
  }

  /// Returns a new list of [TimeSlot]s with the booking applied.
  /// Converts required available slots in [startTime..endTime) to [SlotStatus.booked].
  List<TimeSlot> applyBooking({
    required List<TimeSlot> schedule,
    required TimeOfDay startTime,
    required BookingDuration duration,
  }) {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = startMins + duration.minutes;

    return List.unmodifiable(
      schedule.map((slot) {
        if (slot.startMinutes >= startMins && slot.startMinutes < endMins) {
          if (slot.status == SlotStatus.available) {
            return slot.copyWith(status: SlotStatus.booked);
          }
        }
        return slot;
      }).toList(),
    );
  }
}
