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

/// Transitory state emitted when loading or resetting schedule data.
final class BookingLoading extends BookingState {
  const BookingLoading();
}

/// Main operational state for the booking feature.
final class BookingLoaded extends BookingState {
  const BookingLoaded({required this.schedule, this.isConfirmed = false});

  final BookingSchedule schedule;
  final bool isConfirmed;

  @override
  List<Object?> get props => [schedule, isConfirmed];
}

/// State emitted when an unrecoverable failure occurs.
final class BookingFailure extends BookingState {
  const BookingFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
