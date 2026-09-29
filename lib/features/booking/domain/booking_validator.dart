import 'package:flutter/material.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// Working day boundaries.
const TimeOfDay kDayStartTime = TimeOfDay(hour: 9, minute: 0);
const TimeOfDay kDayEndTime = TimeOfDay(hour: 18, minute: 0);

/// Encapsulates the resulting start time and duration after processing a slot tap.
final class SlotSelectionResult {
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
    // if there is no currentStart, which means it is the first tap
    if (currentStart == null) {
      return _handleInitialSelection(tappedTime, currentDuration);
    }

    // make all time calculations in minutes
    final startMins = currentStart.hour * 60 + currentStart.minute;
    final currentSlots = currentDuration.slotCount; // 1,2,3,4
    final endMins = startMins + currentSlots * 30;
    final tappedMins = tappedTime.hour * 60 + tappedTime.minute;

    // if the tapped time is inside the current selection range
    // notice we put >= in the start and < in the end
    if (tappedMins >= startMins && tappedMins < endMins) {
      return _handleInsideSelection(
        tappedMins: tappedMins,
        startMins: startMins,
        currentSlots: currentSlots,
        currentStart: currentStart,
      );
    }

    // if the user tapped in the next slot of selection slots
    // and there are less than 4 slots
    // it will extend the selection and time duration range
    if (tappedMins == endMins && currentSlots < 4) {
      return _handleExtendSelectionAfter(
        currentSlots: currentSlots,
        currentStart: currentStart,
      );
    }

    // if the user tapped in the previous slot of selection slots
    // and there are less than 4 slots
    // it will extend the selection and time duration range
    // but in the opposite direction
    if (tappedMins == startMins - 30 && currentSlots < 4) {
      return _handleExtendSelectionBefore(
        currentSlots: currentSlots,
        tappedTime: tappedTime,
      );
    }

    // else if all of these conditions are not true
    // it will return the tappedTime only
    return _handleNewSelection(tappedTime);
  }

  //==============================================================================
  // these next four methods are helpers for calculateSelectionOnTap
  // To follow single responsibility principle
  SlotSelectionResult _handleInitialSelection(
    TimeOfDay tappedTime,
    BookingDuration currentDuration,
  ) {
    return SlotSelectionResult(
      selectedStart: tappedTime,
      duration: currentDuration,
      isDeselected: false,
    );
  }

  SlotSelectionResult _handleInsideSelection({
    required int tappedMins,
    required int startMins,
    required int currentSlots,
    required TimeOfDay currentStart,
  }) {
    final index = (tappedMins - startMins) ~/ 30;

    // if it one slot is selected,
    // and the user taps on it again, we need to clear the selection
    if (currentSlots == 1) {
      return const SlotSelectionResult(
        selectedStart: null,
        duration: BookingDuration.thirtyMinutes,
        isDeselected: true,
      );
    }

    // if there more one slot is selected, and the user taps on the first slot,
    // so we need to deselect the first slot and make the next slot the new start
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

    // if there more one slot is selected, and the user taps on the last slot,
    // so we need to deselect the last slot and make the previous slot the new start
    return SlotSelectionResult(
      selectedStart: currentStart,
      duration: _durationFromSlotCount(index),
      isDeselected: false,
    );
  }

  SlotSelectionResult _handleExtendSelectionAfter({
    required int currentSlots,
    required TimeOfDay currentStart,
  }) {
    return SlotSelectionResult(
      selectedStart: currentStart,
      duration: _durationFromSlotCount(currentSlots + 1),
      isDeselected: false,
    );
  }

  SlotSelectionResult _handleExtendSelectionBefore({
    required int currentSlots,
    required TimeOfDay tappedTime,
  }) {
    return SlotSelectionResult(
      selectedStart: tappedTime,
      duration: _durationFromSlotCount(currentSlots + 1),
      isDeselected: false,
    );
  }

  SlotSelectionResult _handleNewSelection(TimeOfDay tappedTime) {
    return SlotSelectionResult(
      selectedStart: tappedTime,
      duration: BookingDuration.thirtyMinutes,
      isDeselected: false,
    );
  }
  //==============================================================================

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
    // i see that because the only rule you can't do xox
    // which means the first and last slots can't be gaps
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
