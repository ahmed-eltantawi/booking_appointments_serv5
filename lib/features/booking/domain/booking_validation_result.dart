import 'package:equatable/equatable.dart';

/// Semantic reason why a booking attempt is invalid.
/// Used by the presentation layer to display a localized error message.
/// Business logic returns this enum; UI converts it to a localized string.
enum BookingInvalidReason {
  /// The booking's end time would exceed 6:00 PM (working day boundary).
  exceedsWorkingHours,

  /// One or more required consecutive slots are already booked.
  /// This also covers all overlap scenarios — any required slot being booked
  /// implicitly means the new booking overlaps an existing one.
  containsBookedSlot,

  /// One or more required consecutive slots are marked unavailable.
  containsUnavailableSlot,

  /// The booking would leave an isolated 30-minute free slot surrounded on
  /// both sides by occupied slots in the resulting schedule.
  createsInvalidGap,
}

/// The outcome of a booking validation attempt.
///
/// [isValid] = true → booking may proceed.
/// [isValid] = false → [reason] is non-null and describes the violation.
class BookingValidationResult extends Equatable {
  const BookingValidationResult._({
    required this.isValid,
    this.reason,
    this.conflictingTimeLabels = const [],
  });

  /// Creates a valid result (booking may proceed).
  const BookingValidationResult.valid() : this._(isValid: true);

  /// Creates an invalid result with a specific [reason] and optional [conflictingTimeLabels].
  const BookingValidationResult.invalid(
    BookingInvalidReason reason, {
    List<String> conflictingTimeLabels = const [],
  })  : this._(
          isValid: false,
          reason: reason,
          conflictingTimeLabels: conflictingTimeLabels,
        );

  final bool isValid;
  final BookingInvalidReason? reason;
  final List<String> conflictingTimeLabels;

  @override
  List<Object?> get props => [isValid, reason, conflictingTimeLabels];
}
