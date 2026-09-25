import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/booking_validator.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// Value object representing the immutable state of the booking schedule.
class BookingSchedule extends Equatable {
  const BookingSchedule({
    required this.slots,
    required this.selectedDuration,
    required this.validStartTimes,
    this.selectedStart,
    this.validationResult,
  });

  /// The current schedule time slots (domain status: available, booked, unavailable).
  final List<TimeSlot> slots;

  /// The selected booking duration.
  final BookingDuration selectedDuration;

  /// Valid start slot times for the selected duration.
  final List<TimeOfDay> validStartTimes;

  /// Currently selected start slot time, if any.
  final TimeOfDay? selectedStart;

  /// Result of booking validation for the current selection, if evaluated.
  final BookingValidationResult? validationResult;

  /// Derived calculated end time (selectedStart + selectedDuration).
  TimeOfDay? get selectedEnd => selectedStart == null
      ? null
      : BookingValidator.calculateEndTime(selectedStart!, selectedDuration);

  BookingSchedule copyWith({
    List<TimeSlot>? slots,
    BookingDuration? selectedDuration,
    List<TimeOfDay>? validStartTimes,
    TimeOfDay? selectedStart,
    BookingValidationResult? validationResult,
    bool clearSelection = false,
  }) {
    return BookingSchedule(
      slots: slots ?? this.slots,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      validStartTimes: validStartTimes ?? this.validStartTimes,
      selectedStart:
          clearSelection ? null : (selectedStart ?? this.selectedStart),
      validationResult:
          clearSelection ? null : (validationResult ?? this.validationResult),
    );
  }

  @override
  List<Object?> get props => [
        slots,
        selectedDuration,
        validStartTimes,
        selectedStart,
        validationResult,
      ];
}
