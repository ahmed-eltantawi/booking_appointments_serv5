import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/data/local_schedule.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_repository.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/booking_validator.dart';
import 'package:booking_appointments/features/booking/domain/time_slot.dart';

/// Concrete implementation of [BookingRepository] handling schedule data state
/// and delegating validation to [BookingValidator].
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    List<TimeSlot>? seedSchedule,
    BookingValidator? validator,
  })  : _originalSlots = seedSchedule ?? initialSchedule,
        _baseSlots = List.from(seedSchedule ?? initialSchedule),
        _validator = validator ?? const BookingValidator();

  static const _defaultDuration = BookingDuration.thirtyMinutes;

  /// Seed schedule data.
  final List<TimeSlot> _originalSlots;

  /// Authoritative current schedule (without display overlays).
  List<TimeSlot> _baseSlots;

  /// Domain validator service.
  final BookingValidator _validator;

  @override
  Future<Either<Failure, BookingSchedule>> getSchedule() async {
    try {
      final validStarts = _validator.getValidStartTimes(
        schedule: _baseSlots,
        duration: _defaultDuration,
      );
      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: _defaultDuration,
        validStartTimes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to load schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> selectDuration(
    BookingDuration duration,
    TimeOfDay? currentStart,
  ) async {
    try {
      final validStarts = _validator.getValidStartTimes(
        schedule: _baseSlots,
        duration: duration,
        selectedStart: currentStart,
      );

      // ISSUE-002: Preserve selectedStart even when duration changes!
      // Revalidate selectedStart with the new duration.
      if (currentStart != null) {
        final validation = _validator.validateBooking(
          schedule: _baseSlots,
          startTime: currentStart,
          duration: duration,
        );

        return Right(BookingSchedule(
          slots: List.unmodifiable(_baseSlots),
          selectedDuration: duration,
          validStartTimes: validStarts,
          selectedStart: currentStart,
          validationResult: validation,
        ));
      }

      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: duration,
        validStartTimes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to change duration: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> selectStartTime(
    TimeOfDay startTime,
    BookingDuration duration, {
    TimeOfDay? currentStart,
  }) async {
    try {
      final selectionResult = _validator.calculateSelectionOnTap(
        tappedTime: startTime,
        currentStart: currentStart,
        currentDuration: duration,
      );

      if (selectionResult.isDeselected) {
        final validStarts = _validator.getValidStartTimes(
          schedule: _baseSlots,
          duration: selectionResult.duration,
          selectedStart: null,
        );

        return Right(BookingSchedule(
          slots: List.unmodifiable(_baseSlots),
          selectedDuration: selectionResult.duration,
          validStartTimes: validStarts,
          selectedStart: null,
          validationResult: null,
        ));
      }

      final newStart = selectionResult.selectedStart!;
      final newDuration = selectionResult.duration;

      final validStarts = _validator.getValidStartTimes(
        schedule: _baseSlots,
        duration: newDuration,
        selectedStart: newStart,
      );

      final validation = _validator.validateBooking(
        schedule: _baseSlots,
        startTime: newStart,
        duration: newDuration,
      );

      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: newDuration,
        validStartTimes: validStarts,
        selectedStart: newStart,
        validationResult: validation,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to select start time: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> confirmBooking({
    required TimeOfDay startTime,
    required BookingDuration duration,
  }) async {
    try {
      final validation = _validator.validateBooking(
        schedule: _baseSlots,
        startTime: startTime,
        duration: duration,
      );

      if (!validation.isValid) {
        final validStarts = _validator.getValidStartTimes(
          schedule: _baseSlots,
          duration: duration,
          selectedStart: startTime,
        );

        return Right(BookingSchedule(
          slots: List.unmodifiable(_baseSlots),
          selectedDuration: duration,
          validStartTimes: validStarts,
          selectedStart: startTime,
          validationResult: validation,
        ));
      }

      // Apply booking to base schedule
      _baseSlots = List.from(
        _validator.applyBooking(
          schedule: _baseSlots,
          startTime: startTime,
          duration: duration,
        ),
      );

      final validStarts = _validator.getValidStartTimes(
        schedule: _baseSlots,
        duration: _defaultDuration,
      );

      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: _defaultDuration,
        validStartTimes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to confirm booking: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> resetSchedule() async {
    try {
      _baseSlots = List.from(_originalSlots);
      final validStarts = _validator.getValidStartTimes(
        schedule: _baseSlots,
        duration: _defaultDuration,
      );
      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: _defaultDuration,
        validStartTimes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to reset schedule: $e'));
    }
  }
}
