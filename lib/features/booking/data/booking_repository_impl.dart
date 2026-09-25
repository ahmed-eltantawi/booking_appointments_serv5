import 'package:booking_appointments/core/errors/either.dart';
import 'package:booking_appointments/core/errors/failures.dart';
import 'package:booking_appointments/features/booking/data/local_schedule.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_repository.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/booking_validator.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

/// Concrete implementation of [BookingRepository] handling business logic
/// and schedule data state.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({List<SlotModel>? seedSchedule})
      : _originalSlots = seedSchedule ?? initialSchedule,
        _baseSlots = List.from(seedSchedule ?? initialSchedule);

  static const _defaultDuration = BookingDuration.thirtyMinutes;

  /// Seed schedule data.
  final List<SlotModel> _originalSlots;

  /// Authoritative current schedule (without display overlays).
  List<SlotModel> _baseSlots;

  @override
  Future<Either<Failure, BookingSchedule>> getSchedule() async {
    try {
      final validStarts = getValidStartIndexes(_baseSlots, _defaultDuration);
      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: _defaultDuration,
        validStartIndexes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to load schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> selectDuration(
    BookingDuration duration,
    int? currentStartIndex,
  ) async {
    try {
      final validStarts = getValidStartIndexes(_baseSlots, duration);

      // Preserve selection if previously selected start is still valid
      if (currentStartIndex != null && validStarts.contains(currentStartIndex)) {
        final endIndex = calculateEndIndex(currentStartIndex, duration);
        final validation = validateBooking(
          slots: _baseSlots,
          startIndex: currentStartIndex,
          duration: duration,
        );
        final displaySlots =
            _buildDisplaySlots(_baseSlots, currentStartIndex, endIndex);

        return Right(BookingSchedule(
          slots: displaySlots,
          selectedDuration: duration,
          validStartIndexes: validStarts,
          selectedStartIndex: currentStartIndex,
          selectedEndIndex: endIndex,
          validationResult: validation,
        ));
      }

      // Clear selection if current start is no longer valid
      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: duration,
        validStartIndexes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to change duration: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> selectStartTime(
    int slotIndex,
    BookingDuration duration,
  ) async {
    try {
      final validStarts = getValidStartIndexes(_baseSlots, duration);
      final endIndex = calculateEndIndex(slotIndex, duration);
      final validation = validateBooking(
        slots: _baseSlots,
        startIndex: slotIndex,
        duration: duration,
      );
      final displaySlots =
          _buildDisplaySlots(_baseSlots, slotIndex, endIndex);

      return Right(BookingSchedule(
        slots: displaySlots,
        selectedDuration: duration,
        validStartIndexes: validStarts,
        selectedStartIndex: slotIndex,
        selectedEndIndex: endIndex,
        validationResult: validation,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to select start time: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> confirmBooking({
    required int startIndex,
    required BookingDuration duration,
  }) async {
    try {
      // Re-validate against base schedule
      final validation = validateBooking(
        slots: _baseSlots,
        startIndex: startIndex,
        duration: duration,
      );

      if (!validation.isValid) {
        final validStarts = getValidStartIndexes(_baseSlots, duration);
        final endIndex = calculateEndIndex(startIndex, duration);
        final displaySlots =
            _buildDisplaySlots(_baseSlots, startIndex, endIndex);

        return Right(BookingSchedule(
          slots: displaySlots,
          selectedDuration: duration,
          validStartIndexes: validStarts,
          selectedStartIndex: startIndex,
          selectedEndIndex: endIndex,
          validationResult: validation,
        ));
      }

      // Apply booking to base schedule
      _baseSlots = List.from(
        applyBooking(
          slots: _baseSlots,
          startIndex: startIndex,
          duration: duration,
        ),
      );

      final validStarts = getValidStartIndexes(_baseSlots, _defaultDuration);

      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: _defaultDuration,
        validStartIndexes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to confirm booking: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingSchedule>> resetSchedule() async {
    try {
      _baseSlots = List.from(_originalSlots);
      final validStarts = getValidStartIndexes(_baseSlots, _defaultDuration);
      return Right(BookingSchedule(
        slots: List.unmodifiable(_baseSlots),
        selectedDuration: _defaultDuration,
        validStartIndexes: validStarts,
      ));
    } catch (e) {
      return Left(BookingFailure('Failed to reset schedule: $e'));
    }
  }

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
