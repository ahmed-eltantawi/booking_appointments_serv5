part of 'booking_cubit.dart';

/// Base state for the booking feature.
@immutable
sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state before schedule loading starts.
final class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Transitory state emitted when loading schedule data.
final class BookingLoading extends BookingState {
  const BookingLoading();
}

/// Operational state emitted on successful schedule queries or selections.
final class BookingSuccess extends BookingState {
  const BookingSuccess(this.schedule);

  final BookingSchedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// State emitted when a booking is confirmed successfully.
final class BookingConfirmed extends BookingState {
  const BookingConfirmed(this.schedule);

  final BookingSchedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// State emitted when an unrecoverable failure occurs.
final class BookingFailure extends BookingState {
  const BookingFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
