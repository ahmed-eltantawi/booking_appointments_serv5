import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/usecases/confirm_booking_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/get_schedule_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/reset_schedule_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/select_duration_usecase.dart';
import 'package:booking_appointments/features/booking/domain/usecases/select_start_time_usecase.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required this.getScheduleUseCase,
    required this.selectDurationUseCase,
    required this.selectStartTimeUseCase,
    required this.confirmBookingUseCase,
    required this.resetScheduleUseCase,
  }) : super(const BookingInitial());

  final GetScheduleUseCase getScheduleUseCase;
  final SelectDurationUseCase selectDurationUseCase;
  final SelectStartTimeUseCase selectStartTimeUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final ResetScheduleUseCase resetScheduleUseCase;

  //==============================================================================
  /// Loads initial schedule data and emits [BookingLoaded].
  //==============================================================================
  Future<void> initialize() async {
    // 1. emit loading state first so the UI shows a progress indicator
    emit(const BookingLoading());
    
    // 2. fetch the schedule from the repository
    final result = await getScheduleUseCase();
    
    // 3. fold the result to either failure or loaded state
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (schedule) => emit(BookingLoaded(schedule: schedule)),
    );
  }

  //==============================================================================
  /// Updates selected booking duration and recalculates valid slots.
  //==============================================================================
  Future<void> selectDuration(BookingDuration duration) async {
    // get the current schedule to know if there's already a selected start
    final schedule = _getCurrentSchedule();
    
    // pass the new duration to the use case to validate it against the current selection
    final result = await selectDurationUseCase(
      duration,
      schedule?.selectedStart,
    );
    
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingLoaded(schedule: newSchedule)),
    );
  }

  //==============================================================================
  /// Selects a start time slot and validates selection.
  //==============================================================================
  Future<void> selectStartTime(TimeOfDay startTime) async {
    final schedule = _getCurrentSchedule();
    
    // fallback to 30 minutes if no duration is selected yet
    final duration = schedule?.selectedDuration ?? BookingDuration.thirtyMinutes;
    final currentStart = schedule?.selectedStart;

    // run the selection logic to see if we expand, reduce, or start a new selection
    final result = await selectStartTimeUseCase(
      startTime,
      duration,
      currentStart: currentStart,
    );
    
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingLoaded(schedule: newSchedule)),
    );
  }

  //==============================================================================
  /// Re-validates and commits the currently selected booking.
  //==============================================================================
  Future<void> confirmBooking() async {
    final schedule = _getCurrentSchedule();
    
    // if there's no schedule or no selection, we can't confirm anything
    if (schedule == null || schedule.selectedStart == null) return;

    // attempt to permanently book the selected slots
    final result = await confirmBookingUseCase(
      startTime: schedule.selectedStart!,
      duration: schedule.selectedDuration,
    );

    result.fold(
      (failure) => emit(BookingFailure(failure.message)), 
      (newSchedule) {
        // if the validation result is not valid, just emit the loaded state to show the error
        if (newSchedule.validationResult != null &&
            !newSchedule.validationResult!.isValid) {
          emit(BookingLoaded(schedule: newSchedule));
        } 
        // else the booking is successful, emit loaded with isConfirmed = true
        else {
          emit(BookingLoaded(schedule: newSchedule, isConfirmed: true));
        }
      }
    );
  }

  //==============================================================================
  /// Resets schedule state back to initial seed data.
  //==============================================================================
  Future<void> reset() async {
    // clears out the user's booking from the cache and reloads the original schedule
    final result = await resetScheduleUseCase();
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (newSchedule) => emit(BookingLoaded(schedule: newSchedule)),
    );
  }

  //==============================================================================
  /// Helper to extract current [BookingSchedule] if present.
  //==============================================================================
  BookingSchedule? _getCurrentSchedule() {
    final current = state;
    // only return the schedule if we are in the loaded state
    if (current is BookingLoaded) return current.schedule;
    return null;
  }
}
