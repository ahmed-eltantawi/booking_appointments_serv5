import 'package:flutter/material.dart';
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
/// are encapsulated in [BookingRepository] and domain services.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository) : super(const BookingInitial());

  final BookingRepository _repository;

  /// Loads initial schedule data and emits [BookingLoaded].
  Future<void> initialize() async {
    emit(const BookingLoading());
    final result = await _repository.getSchedule();
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (schedule) => emit(BookingLoaded(schedule: schedule)),
    );
  }

  /// Updates selected booking duration and recalculates valid slots.
  Future<void> selectDuration(BookingDuration duration) async {
    final schedule = _getCurrentSchedule();
    final result = await _repository.selectDuration(
      duration,
      schedule?.selectedStart,
    );
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingLoaded(schedule: newSchedule)),
    );
  }

  /// Selects a start time slot and validates selection.
  Future<void> selectStartTime(TimeOfDay startTime) async {
    final schedule = _getCurrentSchedule();
    final duration =
        schedule?.selectedDuration ?? BookingDuration.thirtyMinutes;
    final currentStart = schedule?.selectedStart;

    final result = await _repository.selectStartTime(
      startTime,
      duration,
      currentStart: currentStart,
    );
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingLoaded(schedule: newSchedule)),
    );
  }

  /// Re-validates and commits the currently selected booking.
  Future<void> confirmBooking() async {
    final schedule = _getCurrentSchedule();
    if (schedule == null || schedule.selectedStart == null) return;

    final result = await _repository.confirmBooking(
      startTime: schedule.selectedStart!,
      duration: schedule.selectedDuration,
    );

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) {
        if (newSchedule.validationResult != null &&
            !newSchedule.validationResult!.isValid) {
          emit(BookingLoaded(schedule: newSchedule));
        } else {
          emit(BookingLoaded(schedule: newSchedule, isConfirmed: true));
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
      (newSchedule) => emit(BookingLoaded(schedule: newSchedule)),
    );
  }

  /// Helper to extract current [BookingSchedule] if present.
  BookingSchedule? _getCurrentSchedule() {
    final current = state;
    if (current is BookingLoaded) return current.schedule;
    return null;
  }
}
