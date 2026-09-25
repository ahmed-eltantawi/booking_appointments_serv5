import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// The domain status of an individual time slot in the schedule.
///
/// Selection and validation status are presentation concerns and must not be
/// placed in domain slot status.
enum SlotStatus {
  /// Slot is free and may be booked.
  available,

  /// Slot is occupied by an existing appointment.
  booked,

  /// Slot is blocked and cannot be booked (e.g. break, maintenance).
  unavailable,
}

/// A time slot representing a specific time interval within a working day.
class TimeSlot extends Equatable {
  const TimeSlot({
    required this.start,
    required this.end,
    required this.status,
  });

  /// The start time of this slot (e.g. 09:00 AM).
  final TimeOfDay start;

  /// The end time of this slot (e.g. 09:30 AM).
  final TimeOfDay end;

  /// The domain state of this slot (available, booked, unavailable).
  final SlotStatus status;

  /// Total minutes from midnight for the start time.
  int get startMinutes => start.hour * 60 + start.minute;

  /// Total minutes from midnight for the end time.
  int get endMinutes => end.hour * 60 + end.minute;

  /// Duration of this time slot in minutes.
  int get durationInMinutes => endMinutes - startMinutes;

  TimeSlot copyWith({
    TimeOfDay? start,
    TimeOfDay? end,
    SlotStatus? status,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [start, end, status];
}
