part of 'booking_cubit.dart';

/// Lifecycle phase of the booking screen.
enum BookingStatus {
  /// User is browsing — no start time selected.
  idle,

  /// User has tapped a start time (selection may be valid or invalid).
  selected,

  /// A booking was just successfully confirmed.
  /// The [BookingData.slots] list reflects the updated schedule.
  confirmed,
}

@immutable
sealed class BookingState {
  const BookingState();
}
