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

  ///* True if the tap resulted in clearing the active selection.
  final bool isDeselected;
}

class BookingValidator {
  const BookingValidator();

  //==============================================================================
  //! This Method is important one
  ///* It processes a tap on a slot and returns the resulting start time and duration.
  ///* 1. if there is no currentStart it will return the tappedTime
  ///* 2. if the tapped time is inside the current selection range,
  ///*      it will deselect the slot or reduce the selection range
  ///* 3. if the tapped time is outside the current selection range,
  ///*      it will extend the selection range (before or after)
  ///* 4. else it will return the tappedTime and remove the current selection
  //==============================================================================
  SlotSelectionResult calculateSelectionOnTap({
    required TimeOfDay tappedTime,
    required TimeOfDay? currentStart,
    required BookingDuration currentDuration,
  }) {
    // if there is no currentStart it will return the tappedTime
    if (currentStart == null) {
      return SlotSelectionResult(
        selectedStart: tappedTime,
        duration: currentDuration,
        isDeselected: false,
      );
    }

    //* if the currentStart not null, which means there is an active selection before

    // calculate the startMins
    final startMins = currentStart.hour * 60 + currentStart.minute;

    // calculate the endMins, if duration is 30 min => .slotCount = 1
    final currentSlots = currentDuration.slotCount;
    final endMins = startMins + currentSlots * 30;

    // calculate the tappedMins
    final tappedMins = tappedTime.hour * 60 + tappedTime.minute;

    // Tapped slot is inside the current selection range [startMins, endMins)
    // which means the user clicked on an already selected slot
    if (tappedMins >= startMins && tappedMins < endMins) {
      final index = (tappedMins - startMins) ~/ 30;

      // if there is only 1 slot, it will return deselected
      // for example user click in the same time slot twice
      if (currentSlots == 1) {
        return const SlotSelectionResult(
          selectedStart: null,
          duration: BookingDuration.thirtyMinutes,
          isDeselected: true,
        );
      }

      // if the user selected more than one slot, then click again
      // on the first slot, it will reassign the start time to the next slot
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

      // if the user selected more than one slot, then click again
      // on any slot except the first slot, it will cut the selection on the right
      return SlotSelectionResult(
        selectedStart: currentStart,
        duration: _durationFromSlotCount(index),
        isDeselected: false,
      );
    }

    // If the tapped slot is immediately after the current selection,
    // extend the selection to include it,
    // but making sure it doesn't exceed 4 slots
    if (tappedMins == endMins) {
      if (currentSlots < 4) {
        return SlotSelectionResult(
          selectedStart: currentStart,
          duration: _durationFromSlotCount(currentSlots + 1),
          isDeselected: false,
        );
      }
    }

    // If the tapped slot is immediately before the current selection,
    // extend the selection to include it,
    // but making sure it doesn't exceed 4 slots
    if (tappedMins == startMins - 30) {
      if (currentSlots < 4) {
        return SlotSelectionResult(
          selectedStart: tappedTime,
          duration: _durationFromSlotCount(currentSlots + 1),
          isDeselected: false,
        );
      }
    }

    // else the tapped slot is outside the current selection range
    // the tapped slot will be the start of a new selection whit 30 min duration
    return SlotSelectionResult(
      selectedStart: tappedTime,
      duration: BookingDuration.thirtyMinutes,
      isDeselected: false,
    );
  }

  /// This method is used to calculate booking duration from slot count
  /// then it will return the duration from [BookingDuration] enum
  static BookingDuration _durationFromSlotCount(int count) {
    return switch (count) {
      1 => BookingDuration.thirtyMinutes,
      2 => BookingDuration.oneHour,
      3 => BookingDuration.oneHalfHour,
      _ => BookingDuration.twoHours,
    };
  }

  /// calculates the end time with [startTime] and [duration]
  static TimeOfDay calculateEndTime(
    TimeOfDay startTime,
    BookingDuration duration,
  ) {
    final totalMinutes =
        startTime.hour * 60 + startTime.minute + duration.minutes;
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
      return slot.startMinutes >= startMins && slot.startMinutes < endMins;
    }).toList();
  }

  /// Returns all isolated gap start times in [schedule]
  // we use set instead of list to avoid duplicates
  Set<TimeOfDay> getIsolatedGapStartTimes(List<TimeSlot> slots) {
    final gaps = <TimeOfDay>{};

    // if there are less than 3 slots, there can't be any gaps
    if (slots.length < 3) return gaps;

    // we start with 1 instead of 0, and end with length - 1
    // because the first and last slots can't be gaps
    for (var i = 1; i < slots.length - 1; i++) {
      final current = slots[i];

      // make sure the current slot is available
      if (current.status != SlotStatus.available) continue;

      // check if the previous and next slots are occupied(busy)
      final prev = slots[i - 1];
      final next = slots[i + 1];

      if (prev.isOccupied && next.isOccupied) {
        gaps.add(current.start);
      }
    }
    return gaps;
  }

  /// it gives a list of valid start slot times
  List<TimeOfDay> getValidStartTimes({
    required List<TimeSlot> schedule,
    required BookingDuration duration,
    TimeOfDay? selectedStart,
    TimeOfDay dayEndTime = kDayEndTime,
  }) {
    final validStarts = <TimeOfDay>[];
    for (final slot in schedule) {
      if (slot.status != SlotStatus.available) continue;

      // here we make a simulation of user selection
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

    // make sure the start time is within working hours
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

    // if required slots are not enough
    if (requiredSlots.length < duration.slotCount) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.exceedsWorkingHours,
      );
    }

    // check if any of the required slots are already Booked
    final bookedSlots = requiredSlots.where((s) => s.isBooked).toList();
    if (bookedSlots.isNotEmpty) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.containsBookedSlot,
      );
    }

    /// check if any of the required slots are unavailable
    final unavailableSlots = requiredSlots
        .where((s) => s.status == SlotStatus.unavailable)
        .toList();
    if (unavailableSlots.isNotEmpty) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.containsUnavailableSlot,
      );
    }

    // --- Rule 5: Gap rule — reject ONLY newly created isolated gaps ---
    ///* do the simulation of booking is awesome
    /// it see the current isolated gaps and simulate a new booking
    /// and see if the new booking creates new isolated gaps or not

    final isolatedBefore = getIsolatedGapStartTimes(schedule);
    final simulatedSchedule = applyBooking(
      schedule: schedule,
      startTime: startTime,
      duration: duration,
    );
    final isolatedAfter = getIsolatedGapStartTimes(simulatedSchedule);

    final newlyCreatedGaps = isolatedAfter.where(
      (gapTime) => !isolatedBefore.contains(gapTime),
    );
    if (newlyCreatedGaps.isNotEmpty) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.createsInvalidGap,
      );
    }
    // if the time slot across all these rules it's for sure valid
    return const BookingValidationResult.valid();
  }

  /// this method is made for simulating a new booking
  /// it take a copy of the schedule and apply the new booking
  List<TimeSlot> applyBooking({
    required List<TimeSlot> schedule,
    required TimeOfDay startTime,
    required BookingDuration duration,
    String? userId,
  }) {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = startMins + duration.minutes;

    // List.unmodifiable = read-only list
    return List.unmodifiable(
      schedule.map((slot) {
        if (slot.startMinutes >= startMins && slot.startMinutes < endMins) {
          if (slot.status == SlotStatus.available) {
            return slot.copyWith(
              status: SlotStatus.myBooking,
              bookedBy: userId,
            );
          }
        }
        return slot;
      }).toList(),
    );
  }
}
