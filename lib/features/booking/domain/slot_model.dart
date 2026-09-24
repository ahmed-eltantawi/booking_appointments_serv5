import 'package:equatable/equatable.dart';

/// The status of an individual 30-minute time slot in the schedule.
enum SlotStatus {
  /// Slot is free and may be booked.
  available,

  /// Slot is occupied by an existing appointment.
  booked,

  /// Slot is blocked and cannot be booked (e.g. break, maintenance).
  unavailable,

  /// Slot is part of the user's current in-progress selection (display only).
  selected,
}

///* Returns a 12-hour formatted time label for the given slot [index].
///* Valid for index 0 (09:00 AM) through index 18 (06:00 PM — end of working day).
///* Exported here so both [SlotModel] and booking_validator.dart can use it
///* without creating a circular dependency.
String slotIndexToTimeLabel(int index) {
  final totalMinutes = 9 * 60 + index * 30;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  final period = hours < 12 ? 'AM' : 'PM';
  final displayHour = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours);
  return '$displayHour:${minutes.toString().padLeft(2, '0')} $period';
}

/// A single 30-minute time slot in the booking schedule.
class SlotModel extends Equatable {
  const SlotModel({
    required this.index,
    required this.status,
  });

  /// 0-based index within the working day (0 = 09:00 AM, 17 = 05:30 PM).
  final int index;

  /// The current state of this slot.
  final SlotStatus status;

  /// Human-readable 12-hour formatted time label for this slot's start time.
  String get timeLabel => slotIndexToTimeLabel(index);

  SlotModel copyWith({SlotStatus? status}) {
    return SlotModel(
      index: index,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [index, status];
}
