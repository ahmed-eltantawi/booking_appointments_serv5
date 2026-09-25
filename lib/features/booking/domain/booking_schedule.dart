import 'package:equatable/equatable.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

/// Value object representing the current state of the booking schedule.
class BookingSchedule extends Equatable {
  const BookingSchedule({
    required this.slots,
    required this.selectedDuration,
    required this.validStartIndexes,
    this.selectedStartIndex,
    this.selectedEndIndex,
    this.validationResult,
  });

  /// The current schedule slots (including any selection overlays).
  final List<SlotModel> slots;

  /// The selected booking duration.
  final BookingDuration selectedDuration;

  /// Valid start slot indexes for the selected duration.
  final List<int> validStartIndexes;

  /// Currently selected start slot index, if any.
  final int? selectedStartIndex;

  /// Currently selected end slot index, if any.
  final int? selectedEndIndex;

  /// Result of booking validation, if evaluated.
  final BookingValidationResult? validationResult;

  BookingSchedule copyWith({
    List<SlotModel>? slots,
    BookingDuration? selectedDuration,
    List<int>? validStartIndexes,
    int? selectedStartIndex,
    int? selectedEndIndex,
    BookingValidationResult? validationResult,
    bool clearSelection = false,
  }) {
    return BookingSchedule(
      slots: slots ?? this.slots,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      validStartIndexes: validStartIndexes ?? this.validStartIndexes,
      selectedStartIndex:
          clearSelection ? null : (selectedStartIndex ?? this.selectedStartIndex),
      selectedEndIndex:
          clearSelection ? null : (selectedEndIndex ?? this.selectedEndIndex),
      validationResult:
          clearSelection ? null : (validationResult ?? this.validationResult),
    );
  }

  @override
  List<Object?> get props => [
        slots,
        selectedDuration,
        validStartIndexes,
        selectedStartIndex,
        selectedEndIndex,
        validationResult,
      ];
}
