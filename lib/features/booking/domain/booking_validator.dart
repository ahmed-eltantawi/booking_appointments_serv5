import 'package:flutter/material.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// Working day boundaries.
const TimeOfDay kDayStartTime = TimeOfDay(hour: 9, minute: 0);
const TimeOfDay kDayEndTime = TimeOfDay(hour: 18, minute: 0);

/// Encapsulates the resulting start time and duration after processing a slot tap.
class SlotSelectionResult {
  const SlotSelectionResult({
    required this.selectedStart,
    required this.duration,
    required this.isDeselected,
  });

  /// The new selected start time, or null if the selection was cleared/deselected.
  final TimeOfDay? selectedStart;

  /// The calculated selected duration.
  final BookingDuration duration;

  /// True if the tap resulted in clearing the active selection.
  final bool isDeselected;
}

/// Core domain service for appointment scheduling and validation rules.
///
/// Encapsulates all business logic for slot availability, working hours,
/// conflict detection, and gap detection without Flutter UI dependencies.
class BookingValidator {
  const BookingValidator();

  /// Calculates the updated selection ([TimeOfDay? selectedStart], [BookingDuration duration], [bool isDeselected])
  /// when a slot at [tappedTime] is tapped, given the current [currentStart] and [currentDuration].
  SlotSelectionResult calculateSelectionOnTap({
    required TimeOfDay tappedTime,
    required TimeOfDay? currentStart,
    required BookingDuration currentDuration,
  }) {
    if (currentStart == null) {
      return SlotSelectionResult(
        selectedStart: tappedTime,
        duration: currentDuration,
        isDeselected: false,
      );
    }

    final startMins = currentStart.hour * 60 + currentStart.minute;
    final currentSlots = currentDuration.slotCount;
    final endMins = startMins + currentSlots * 30;
    final tappedMins = tappedTime.hour * 60 + tappedTime.minute;

    // Tapped slot is inside the current selection range [startMins, endMins)
    if (tappedMins >= startMins && tappedMins < endMins) {
      final index = (tappedMins - startMins) ~/ 30;

      if (currentSlots == 1) {
        return const SlotSelectionResult(
          selectedStart: null,
          duration: BookingDuration.thirtyMinutes,
          isDeselected: true,
        );
      }

      if (index == 0) {
        final newStartMins = startMins + 30;
        final newStart = TimeOfDay(
          hour: (newStartMins ~/ 60) % 24,
          minute: newStartMins % 60,
        );
        return SlotSelectionResult(
          selectedStart: newStart,
          duration: _durationFromSlotCount(currentSlots - 1),
          isDeselected: false,
        );
      }

      return SlotSelectionResult(
        selectedStart: currentStart,
        duration: _durationFromSlotCount(index),
        isDeselected: false,
      );
    }

    // Tapped slot is unselected: check adjacency to current range [startMins, endMins)
    if (tappedMins == endMins) {
      if (currentSlots < 4) {
        return SlotSelectionResult(
          selectedStart: currentStart,
          duration: _durationFromSlotCount(currentSlots + 1),
          isDeselected: false,
        );
      }
    }

    if (tappedMins == startMins - 30) {
      if (currentSlots < 4) {
        return SlotSelectionResult(
          selectedStart: tappedTime,
          duration: _durationFromSlotCount(currentSlots + 1),
          isDeselected: false,
        );
      }
    }

    return SlotSelectionResult(
      selectedStart: tappedTime,
      duration: BookingDuration.thirtyMinutes,
      isDeselected: false,
    );
  }

  static BookingDuration _durationFromSlotCount(int count) {
    return switch (count) {
      1 => BookingDuration.thirtyMinutes,
      2 => BookingDuration.oneHour,
      3 => BookingDuration.oneHalfHour,
      _ => BookingDuration.twoHours,
    };
  }

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
  ///
  /// Takes [selectedStart] into account when evaluating slot validity so that
  /// neighboring slots (which extend/modify an active selection into a valid
  /// multi-slot booking) are correctly identified as valid.
  List<TimeOfDay> getValidStartTimes({
    required List<TimeSlot> schedule,
    required BookingDuration duration,
    TimeOfDay? selectedStart,
    TimeOfDay dayEndTime = kDayEndTime,
  }) {
    final validStarts = <TimeOfDay>[];
    for (final slot in schedule) {
      if (slot.status != SlotStatus.available) continue;

      final selectionResult = calculateSelectionOnTap(
        tappedTime: slot.start,
        currentStart: selectedStart,
        currentDuration: duration,
      );

      if (selectionResult.isDeselected) {
        validStarts.add(slot.start);
      } else {
        final result = validateBooking(
          schedule: schedule,
          startTime: selectionResult.selectedStart,
          duration: selectionResult.duration,
          dayEndTime: dayEndTime,
        );
        if (result.isValid) {
          validStarts.add(slot.start);
        }
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
