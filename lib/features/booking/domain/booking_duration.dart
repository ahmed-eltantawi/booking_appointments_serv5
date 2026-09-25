/// BookingDuration — the selectable appointment durations.
/// Internally, duration is measured in 30-minute slot units.
enum BookingDuration {
  thirtyMinutes,
  oneHour,
  oneHalfHour,
  twoHours,
}

extension BookingDurationX on BookingDuration {
  /// Number of consecutive 30-minute slots required for this duration.
  int get slotCount => switch (this) {
    BookingDuration.thirtyMinutes => 1,
    BookingDuration.oneHour       => 2,
    BookingDuration.oneHalfHour   => 3,
    BookingDuration.twoHours      => 4,
  };

  /// Total duration in minutes.
  int get minutes => slotCount * 30;
}

