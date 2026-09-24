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

/// Emitted before [BookingCubit.initialize] completes.
/// Used to show a loading placeholder in the UI.
final class BookingInitial extends BookingState {
  const BookingInitial();
}

/// The primary operational state. Emitted after initialization and on every
/// user interaction (duration change, slot tap, reset, confirm).
///
/// All fields required by the UI are present in a single flat object.
/// No copyWith is provided — the cubit always emits complete fresh instances
/// to keep the state construction explicit and the nullable fields unambiguous.
final class BookingData extends BookingState {
  const BookingData({
    required this.slots,
    required this.selectedDuration,
    required this.validStartIndexes,
    required this.status,
    this.selectedStartIndex,
    this.selectedEndIndex,
    this.validationResult,
  });

  /// The current display schedule. Slots in the user's selection have
  /// [SlotStatus.selected]; all other slots reflect the base schedule.
  final List<SlotModel> slots;

  /// The duration chip currently selected by the user.
  final BookingDuration selectedDuration;

  /// Slot indexes that are tappable as valid start times for [selectedDuration].
  /// Computed by [getValidStartIndexes] (includes gap-rule filtering).
  final List<int> validStartIndexes;

  /// Current lifecycle phase.
  final BookingStatus status;

  /// The slot index the user tapped as a start time, or null when no selection.
  final int? selectedStartIndex;

  /// Inclusive index of the last occupied slot for the current selection,
  /// or null when no selection or when the booking would exceed working hours.
  final int? selectedEndIndex;

  /// Result of the last [validateBooking] call, or null when idle.
  final BookingValidationResult? validationResult;
}
