import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:booking_appointments/features/booking/data/booking_repository_impl.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/booking_validator.dart';
import 'package:booking_appointments/features/booking/domain/time_slot.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

// Helper to create an 18-slot schedule (09:00 to 18:00) with all available by default
List<TimeSlot> _buildSchedule({
  List<TimeOfDay> booked = const [],
  List<TimeOfDay> unavailable = const [],
}) {
  final slots = <TimeSlot>[];
  var mins = 9 * 60;
  for (var i = 0; i < 18; i++) {
    final start = TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    mins += 30;
    final end = TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    var status = SlotStatus.available;
    if (booked.contains(start)) {
      status = SlotStatus.booked;
    } else if (unavailable.contains(start)) {
      status = SlotStatus.unavailable;
    }
    slots.add(TimeSlot(start: start, end: end, status: status));
  }
  return slots;
}

void main() {
  const validator = BookingValidator();

  group('BookingValidator — calculateEndTime & working hours', () {
    test('calculates end time for 30 min duration', () {
      final end = BookingValidator.calculateEndTime(
        const TimeOfDay(hour: 9, minute: 0),
        BookingDuration.thirtyMinutes,
      );
      expect(end, const TimeOfDay(hour: 9, minute: 30));
    });

    test('calculates end time for 2 hour duration', () {
      final end = BookingValidator.calculateEndTime(
        const TimeOfDay(hour: 16, minute: 0),
        BookingDuration.twoHours,
      );
      expect(end, const TimeOfDay(hour: 18, minute: 0));
    });

    test('rejects booking that exceeds working hours (5:00 PM + 2 hrs)', () {
      final isValid = BookingValidator.isWithinWorkingHours(
        startTime: const TimeOfDay(hour: 17, minute: 0),
        duration: BookingDuration.twoHours,
      );
      expect(isValid, isFalse);
    });

    test('accepts booking ending exactly at 6:00 PM', () {
      final isValid = BookingValidator.isWithinWorkingHours(
        startTime: const TimeOfDay(hour: 16, minute: 0),
        duration: BookingDuration.twoHours,
      );
      expect(isValid, isTrue);
    });
  });

  group('BookingValidator — ISSUE-014: Protect against invalid start values', () {
    test('rejects null start time without crashing', () {
      final result = validator.validateBooking(
        schedule: _buildSchedule(),
        startTime: null,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.exceedsWorkingHours);
    });

    test('rejects invalid start time before 9:00 AM', () {
      final result = validator.validateBooking(
        schedule: _buildSchedule(),
        startTime: const TimeOfDay(hour: 8, minute: 30),
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.exceedsWorkingHours);
    });

    test('rejects invalid start time after 6:00 PM', () {
      final result = validator.validateBooking(
        schedule: _buildSchedule(),
        startTime: const TimeOfDay(hour: 18, minute: 30),
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.exceedsWorkingHours);
    });
  });

  group('BookingValidator — ISSUE-001: X-O-X gap detection', () {
    test('rejects booking that creates a new isolated X-O-X gap', () {
      // Slot 9:00 booked, slot 10:00 booked. Booking 9:00 leaves 9:30 isolated.
      final schedule = _buildSchedule(
        booked: [const TimeOfDay(hour: 10, minute: 0)],
      );
      final result = validator.validateBooking(
        schedule: schedule,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.createsInvalidGap);
    });

    test('allows booking when isolated X-O-X gap existed BEFORE booking', () {
      final schedule = _buildSchedule(
        booked: [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
        ],
      );

      final result = validator.validateBooking(
        schedule: schedule,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    test('treats unavailable slots correctly as occupied for X-O-X gap detection', () {
      final schedule = _buildSchedule(
        booked: [const TimeOfDay(hour: 9, minute: 0)],
        unavailable: [const TimeOfDay(hour: 10, minute: 0)],
      );

      final result = validator.validateBooking(
        schedule: schedule,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    test('X-O-O-X (2 free slots) is not an isolated gap', () {
      final schedule = _buildSchedule(
        booked: [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 30),
        ],
      );
      final gaps = validator.getIsolatedGapStartTimes(schedule);
      expect(gaps, isEmpty);
    });

    test('X-O-O-O-X (3 free slots) is not an isolated gap', () {
      final schedule = _buildSchedule(
        booked: [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
        ],
      );
      final gaps = validator.getIsolatedGapStartTimes(schedule);
      expect(gaps, isEmpty);
    });
  });

  group('BookingValidator — Conflicts & Overlaps', () {
    test('rejects booking overlapping a booked slot', () {
      final schedule = _buildSchedule(
        booked: [const TimeOfDay(hour: 10, minute: 0)],
      );
      final result = validator.validateBooking(
        schedule: schedule,
        startTime: const TimeOfDay(hour: 9, minute: 30),
        duration: BookingDuration.oneHour,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsBookedSlot);
    });

    test('rejects booking overlapping an unavailable slot', () {
      final schedule = _buildSchedule(
        unavailable: [const TimeOfDay(hour: 10, minute: 0)],
      );
      final result = validator.validateBooking(
        schedule: schedule,
        startTime: const TimeOfDay(hour: 9, minute: 30),
        duration: BookingDuration.oneHour,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsUnavailableSlot);
    });
  });

  group('BookingCubit Unit Tests', () {
    late BookingRepositoryImpl repository;

    setUp(() {
      repository = BookingRepositoryImpl();
    });

    blocTest<BookingCubit, BookingState>(
      'initialize() emits BookingLoading then BookingLoaded state',
      build: () => BookingCubit(repository),
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const BookingLoading(),
        isA<BookingLoaded>().having(
          (s) => s.schedule.selectedStart,
          'selectedStart',
          isNull,
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'selectStartTime updates selectedStart and validates',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 30));
      },
      expect: () => [
        const BookingLoading(),
        isA<BookingLoaded>(),
        isA<BookingLoaded>().having(
          (s) => s.schedule.selectedStart,
          'selectedStart',
          const TimeOfDay(hour: 9, minute: 30),
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'ISSUE-002: changing duration keeps selectedStart visible and revalidates (valid -> invalid)',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(const TimeOfDay(hour: 17, minute: 0));
        await cubit.selectDuration(BookingDuration.twoHours);
      },
      verify: (cubit) {
        final state = cubit.state as BookingLoaded;
        expect(state.schedule.selectedStart, const TimeOfDay(hour: 17, minute: 0));
        expect(state.schedule.selectedDuration, BookingDuration.twoHours);
        expect(state.schedule.validationResult!.isValid, isFalse);
        expect(
          state.schedule.validationResult!.reason,
          BookingInvalidReason.exceedsWorkingHours,
        );
      },
    );

    blocTest<BookingCubit, BookingState>(
      'reset restores schedule and clears selection & validation',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(const TimeOfDay(hour: 17, minute: 0));
        await cubit.selectDuration(BookingDuration.twoHours);
        await cubit.reset();
      },
      verify: (cubit) {
        final state = cubit.state as BookingLoaded;
        expect(state.schedule.selectedStart, isNull);
        expect(state.schedule.validationResult?.isValid ?? true, isTrue);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'toggling selected 30-min slot deselects it',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 0));
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 0));
      },
      verify: (cubit) {
        final state = cubit.state as BookingLoaded;
        expect(state.schedule.selectedStart, isNull);
        expect(state.schedule.validationResult, isNull);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'tapping consecutive slots expands duration dynamically (9:00 -> 9:30 -> 10:00 -> 10:30)',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 0));
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 30));
        await cubit.selectStartTime(const TimeOfDay(hour: 10, minute: 0));
        await cubit.selectStartTime(const TimeOfDay(hour: 10, minute: 30));
      },
      verify: (cubit) {
        final state = cubit.state as BookingLoaded;
        expect(state.schedule.selectedStart, const TimeOfDay(hour: 9, minute: 0));
        expect(state.schedule.selectedDuration, BookingDuration.twoHours);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'tapping end slot of multi-slot selection trims range and updates duration',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 0));
        await cubit.selectStartTime(const TimeOfDay(hour: 9, minute: 30));
        await cubit.selectStartTime(const TimeOfDay(hour: 10, minute: 0));
        // Deselect end slot 10:00
        await cubit.selectStartTime(const TimeOfDay(hour: 10, minute: 0));
      },
      verify: (cubit) {
        final state = cubit.state as BookingLoaded;
        expect(state.schedule.selectedStart, const TimeOfDay(hour: 9, minute: 0));
        expect(state.schedule.selectedDuration, BookingDuration.oneHour);
      },
    );
  });

  group('BookingValidator — calculateSelectionOnTap Unit Tests', () {
    test('selects tapped slot with 30 min duration when no prior selection', () {
      final res = validator.calculateSelectionOnTap(
        tappedTime: const TimeOfDay(hour: 9, minute: 0),
        currentStart: null,
        currentDuration: BookingDuration.thirtyMinutes,
      );
      expect(res.selectedStart, const TimeOfDay(hour: 9, minute: 0));
      expect(res.duration, BookingDuration.thirtyMinutes);
      expect(res.isDeselected, isFalse);
    });

    test('toggling same slot deselects when current duration is 30 min', () {
      final res = validator.calculateSelectionOnTap(
        tappedTime: const TimeOfDay(hour: 9, minute: 0),
        currentStart: const TimeOfDay(hour: 9, minute: 0),
        currentDuration: BookingDuration.thirtyMinutes,
      );
      expect(res.selectedStart, isNull);
      expect(res.isDeselected, isTrue);
    });

    test('tapping adjacent slot expands range forward (9:00 + 9:30 -> 1 hr)', () {
      final res = validator.calculateSelectionOnTap(
        tappedTime: const TimeOfDay(hour: 9, minute: 30),
        currentStart: const TimeOfDay(hour: 9, minute: 0),
        currentDuration: BookingDuration.thirtyMinutes,
      );
      expect(res.selectedStart, const TimeOfDay(hour: 9, minute: 0));
      expect(res.duration, BookingDuration.oneHour);
      expect(res.isDeselected, isFalse);
    });

    test('tapping adjacent slot expands range backward (10:00 + 9:30 -> 1 hr starting at 9:30)', () {
      final res = validator.calculateSelectionOnTap(
        tappedTime: const TimeOfDay(hour: 9, minute: 30),
        currentStart: const TimeOfDay(hour: 10, minute: 0),
        currentDuration: BookingDuration.thirtyMinutes,
      );
      expect(res.selectedStart, const TimeOfDay(hour: 9, minute: 30));
      expect(res.duration, BookingDuration.oneHour);
      expect(res.isDeselected, isFalse);
    });

    test('tapping non-adjacent slot resets selection to new slot', () {
      final res = validator.calculateSelectionOnTap(
        tappedTime: const TimeOfDay(hour: 14, minute: 0),
        currentStart: const TimeOfDay(hour: 9, minute: 0),
        currentDuration: BookingDuration.thirtyMinutes,
      );
      expect(res.selectedStart, const TimeOfDay(hour: 14, minute: 0));
      expect(res.duration, BookingDuration.thirtyMinutes);
      expect(res.isDeselected, isFalse);
    });
  });
}
