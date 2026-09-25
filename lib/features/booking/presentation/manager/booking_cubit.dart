import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_repository.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';

part 'booking_state.dart';

/// Orchestrates state management for the booking feature.
///
/// Responsible strictly for handling UI actions, invoking repository methods,
/// and emitting clear lifecycle states. All business math and data updates
/// are encapsulated in [BookingRepository].
class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository) : super(const BookingInitial());

  final BookingRepository _repository;

  /// Loads initial schedule data and emits [BookingSuccess].
  Future<void> initialize() async {
    emit(const BookingLoading());
    final result = await _repository.getSchedule();
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (schedule) => emit(BookingSuccess(schedule)),
    );
  }

  /// Updates selected booking duration and recalculates valid slots.
  Future<void> selectDuration(BookingDuration duration) async {
    final schedule = _getCurrentSchedule();
    final result = await _repository.selectDuration(
      duration,
      schedule?.selectedStartIndex,
    );
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingSuccess(newSchedule)),
    );
  }

  /// Selects a start time slot and validates selection.
  Future<void> selectStartTime(int slotIndex) async {
    final schedule = _getCurrentSchedule();
    final duration =
        schedule?.selectedDuration ?? BookingDuration.thirtyMinutes;
    final result = await _repository.selectStartTime(slotIndex, duration);
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingSuccess(newSchedule)),
    );
  }

  /// Alias method for user slot taps.
  Future<void> handleSlotTap(int slotIndex) async {
    await selectStartTime(slotIndex);
  }

  /// Re-validates and commits the currently selected booking.
  Future<void> confirmBooking() async {
    final schedule = _getCurrentSchedule();
    if (schedule == null || schedule.selectedStartIndex == null) return;

    final result = await _repository.confirmBooking(
      startIndex: schedule.selectedStartIndex!,
      duration: schedule.selectedDuration,
    );

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) {
        if (newSchedule.validationResult != null &&
            !newSchedule.validationResult!.isValid) {
          emit(BookingSuccess(newSchedule));
        } else {
          emit(BookingConfirmed(newSchedule));
        }
      },
    );
  }

  /// Resets schedule state back to initial seed data.
  Future<void> reset() async {
    emit(const BookingLoading());
    final result = await _repository.resetSchedule();
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (schedule) => emit(BookingSuccess(schedule)),
    );
  }

  /// Helper to extract current [BookingSchedule] if present.
  BookingSchedule? _getCurrentSchedule() {
    final current = state;
    if (current is BookingSuccess) return current.schedule;
    if (current is BookingConfirmed) return current.schedule;
    return null;
  }
}
