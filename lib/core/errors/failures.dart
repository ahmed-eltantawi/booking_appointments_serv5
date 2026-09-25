import 'package:equatable/equatable.dart';

/// Abstract base class for all failure representations in the application.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Generic failure returned when a booking operation fails.
class BookingFailure extends Failure {
  const BookingFailure([super.message = 'Booking operation failed']);
}

/// Failure returned when server or network operation fails.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure occurred']);
}

/// Failure returned when a local cache operation fails.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure occurred']);
}
