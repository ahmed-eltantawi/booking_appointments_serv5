import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_appointments/features/booking/data/local_schedule.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/booking_validator.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

part 'booking_state.dart';

/// Manages all booking screen state.
///
/// Flow:
///   User Action → Cubit method → domain functions → emit(BookingData)
///
/// The cubit maintains [_baseSlots] (the actual schedule) separately from the
/// [BookingData.slots] display list (which may include [SlotStatus.selected]
/// overlays). Validators always receive [_baseSlots] — never the display list.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingInitial());

  static const _defaultDuration = BookingDuration.thirtyMinutes;

  //! ===== Internal Schedule =====

  /// The authoritative schedule state (no selection overlay).
  /// Updated only when a booking is confirmed.
  late List<SlotModel> _baseSlots;

  /// The original seed schedule, held for reset operations.
  /// Never modified after construction.
  final List<SlotModel> _originalSlots = initialSchedule;

  //! ===== Public API =====

  /// Loads the initial schedule and emits the first [BookingData] state.
  void initialize() {
    _baseSlots = List.from(_originalSlots);
    final validStarts = getValidStartIndexes(_baseSlots, _defaultDuration);
    emit(BookingData(
      slots: List.unmodifiable(_baseSlots),
      selectedDuration: _defaultDuration,
      validStartIndexes: validStarts,
      status: BookingStatus.idle,
    ));
  }

  /// Changes the selected duration chip and recalculates valid start times.
  ///
  /// If the previously selected start index is still valid for [duration],
  /// the selection is preserved and the end index / validation are updated.
  /// Otherwise the selection is cleared.
  void selectDuration(BookingDuration duration) {
    final current = state;
    if (current is! BookingData) return;

    final validStarts = getValidStartIndexes(_baseSlots, duration);
    final prevStart = current.selectedStartIndex;

    // --- Preserve selection if still valid for the new duration ---
    if (prevStart != null && validStarts.contains(prevStart)) {
      final endIndex = calculateEndIndex(prevStart, duration);
      final validation = validateBooking(
        slots: _baseSlots,
        startIndex: prevStart,
        duration: duration,
      );
      final displaySlots = _buildDisplaySlots(_baseSlots, prevStart, endIndex);
      emit(BookingData(
        slots: displaySlots,
        selectedDuration: duration,
        validStartIndexes: validStarts,
        status: BookingStatus.selected,
        selectedStartIndex: prevStart,
        selectedEndIndex: endIndex,
        validationResult: validation,
      ));
      return;
    }

    // --- Clear selection when previous start is no longer valid ---
    emit(BookingData(
      slots: List.unmodifiable(_baseSlots),
      selectedDuration: duration,
      validStartIndexes: validStarts,
      status: BookingStatus.idle,
    ));
  }

  /// Records the user's start time tap and validates the booking.
  ///
  /// The [slots] in the emitted state include a [SlotStatus.selected] overlay
  /// for the chosen range. The [validationResult] reflects the full validation
  /// including the gap rule.
  void selectStartTime(int slotIndex) {
    final current = state;
    if (current is! BookingData) return;

    final endIndex = calculateEndIndex(slotIndex, current.selectedDuration);
    final validation = validateBooking(
      slots: _baseSlots,
      startIndex: slotIndex,
      duration: current.selectedDuration,
    );
    final displaySlots = _buildDisplaySlots(_baseSlots, slotIndex, endIndex);

    emit(BookingData(
      slots: displaySlots,
      selectedDuration: current.selectedDuration,
      validStartIndexes: current.validStartIndexes,
      status: BookingStatus.selected,
      selectedStartIndex: slotIndex,
      selectedEndIndex: endIndex,
      validationResult: validation,
    ));
  }

  /// Resets the schedule to the original seed data and clears all selections.
  void reset() {
    _baseSlots = List.from(_originalSlots);
    final validStarts = getValidStartIndexes(_baseSlots, _defaultDuration);
    emit(BookingData(
      slots: List.unmodifiable(_baseSlots),
      selectedDuration: _defaultDuration,
      validStartIndexes: validStarts,
      status: BookingStatus.idle,
    ));
  }

  /// Confirms the current booking after re-running full validation.
  ///
  /// Re-validation is mandatory — the UI state may be stale if the schedule
  /// changed between the last [selectStartTime] call and the confirm tap.
  ///
  /// On success: applies the booking to [_baseSlots] and emits a confirmed state.
  /// On failure: emits the current state with the updated [validationResult].
  void confirmBooking() {
    final current = state;
    if (current is! BookingData) return;
    final startIndex = current.selectedStartIndex;
    if (startIndex == null) return;

    // --- Re-validate against the base schedule, not the UI state ---
    final validation = validateBooking(
      slots: _baseSlots,
      startIndex: startIndex,
      duration: current.selectedDuration,
    );

    if (!validation.isValid) {
      // Invalid — update error without applying changes.
      emit(BookingData(
        slots: current.slots,
        selectedDuration: current.selectedDuration,
        validStartIndexes: current.validStartIndexes,
        status: current.status,
        selectedStartIndex: current.selectedStartIndex,
        selectedEndIndex: current.selectedEndIndex,
        validationResult: validation,
      ));
      return;
    }

    // --- Apply booking to the base schedule ---
    _baseSlots = List.from(
      applyBooking(
        slots: _baseSlots,
        startIndex: startIndex,
        duration: current.selectedDuration,
      ),
    );

    final validStarts = getValidStartIndexes(_baseSlots, _defaultDuration);

    emit(BookingData(
      slots: List.unmodifiable(_baseSlots),
      selectedDuration: _defaultDuration,
      validStartIndexes: validStarts,
      status: BookingStatus.confirmed,
    ));
  }

  //! ===== Private Helpers =====

  /// Builds the display slot list by overlaying [SlotStatus.selected] on
  /// all slots in [[startIndex]..[safeEndIndex]].
  ///
  /// When [endIndex] is null (booking exceeds working hours), only [startIndex]
  /// is marked as selected to provide visual feedback for the invalid attempt.
  List<SlotModel> _buildDisplaySlots(
    List<SlotModel> baseSlots,
    int startIndex,
    int? endIndex,
  ) {
    final safeEndIndex = endIndex ?? startIndex;
    return List.unmodifiable(
      baseSlots.map((slot) {
        if (slot.index >= startIndex && slot.index <= safeEndIndex) {
          return slot.copyWith(status: SlotStatus.selected);
        }
        return slot;
      }).toList(),
    );
  }
}
