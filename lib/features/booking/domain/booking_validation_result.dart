import 'package:equatable/equatable.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';

/// Semantic reason why a booking attempt is invalid.
/// Used by the presentation layer to display a localized error message.
enum BookingInvalidReason {
  /// The booking's end time would exceed 6:00 PM (working day boundary).
  exceedsWorkingHours,

  /// One or more required consecutive slots are already booked.
  containsBookedSlot,

  /// One or more required consecutive slots are marked unavailable.
  containsUnavailableSlot,

  /// The booking would leave an isolated 30-minute free slot surrounded on
  /// both sides by occupied slots in the resulting schedule.
  createsInvalidGap,
}

extension BookingInvalidReasonLocalization on BookingInvalidReason {
  /// Centralized single source of truth mapping for localized validation strings.
  String getLocalizedMessage(S l10n) {
    return switch (this) {
      BookingInvalidReason.exceedsWorkingHours => l10n.errorExceedsWorkingHours,
      BookingInvalidReason.containsBookedSlot => l10n.errorContainsBookedSlot,
      BookingInvalidReason.containsUnavailableSlot => l10n.errorContainsUnavailableSlot,
      BookingInvalidReason.createsInvalidGap => l10n.errorCreatesInvalidGap,
    };
  }
}

/// The outcome of a booking validation attempt.
class BookingValidationResult extends Equatable {
  const BookingValidationResult._({
    required this.isValid,
    this.reason,
    this.conflictingTimeLabels = const [],
  });

  /// Creates a valid result (booking may proceed).
  const BookingValidationResult.valid() : this._(isValid: true);

  /// Creates an invalid result with a specific [reason].
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

  /// Returns the localized error message for this validation result.
  String getLocalizedMessage(S l10n) {
    if (isValid || reason == null) return '';
    return reason!.getLocalizedMessage(l10n);
  }

  @override
  List<Object?> get props => [isValid, reason, conflictingTimeLabels];
}
