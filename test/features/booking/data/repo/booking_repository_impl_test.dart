import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:booking_appointments/features/booking/data/repo/booking_repository_impl.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

void main() {
  late BookingRepositoryImpl repository;

  setUp(() {
    repository = BookingRepositoryImpl();
  });

  group('BookingRepositoryImpl Unit Tests', () {
    test('getSchedule returns initial schedule successfully', () async {
      final result = await repository.getSchedule();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not return failure'), (schedule) {
        expect(schedule.slots.length, 18);
        expect(schedule.selectedDuration, BookingDuration.thirtyMinutes);
        expect(schedule.selectedStart, isNull);
      });
    });

    test('selectStartTime updates schedule with selectedStart', () async {
      final result = await repository.selectStartTime(
        const TimeOfDay(hour: 9, minute: 0),
        BookingDuration.thirtyMinutes,
      );

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not return failure'), (schedule) {
        expect(schedule.selectedStart, const TimeOfDay(hour: 9, minute: 0));
      });
    });

    test(
      'confirmBooking applies booking to base schedule when valid',
      () async {
        await repository.selectStartTime(
          const TimeOfDay(hour: 9, minute: 30),
          BookingDuration.thirtyMinutes,
        );
        final confirmResult = await repository.confirmBooking(
          startTime: const TimeOfDay(hour: 9, minute: 30),
          duration: BookingDuration.thirtyMinutes,
        );

        expect(confirmResult.isRight(), isTrue);
        confirmResult.fold((failure) => fail('Should not return failure'), (
          schedule,
        ) {
          expect(
            schedule.slots
                .firstWhere(
                  (s) => s.start == const TimeOfDay(hour: 9, minute: 30),
                )
                .status,
            SlotStatus.myBooking,
          );

          expect(schedule.selectedStart, isNull);
        });
      },
    );

    test('resetSchedule restores initial seed slots', () async {
      await repository.selectStartTime(
        const TimeOfDay(hour: 9, minute: 30),
        BookingDuration.thirtyMinutes,
      );
      await repository.confirmBooking(
        startTime: const TimeOfDay(hour: 9, minute: 30),
        duration: BookingDuration.thirtyMinutes,
      );

      final resetResult = await repository.resetSchedule();

      expect(resetResult.isRight(), isTrue);
      resetResult.fold((failure) => fail('Should not return failure'), (
        schedule,
      ) {
        expect(
          schedule.slots
              .firstWhere(
                (s) => s.start == const TimeOfDay(hour: 9, minute: 30),
              )
              .status,
          SlotStatus.available,
        );
      });
    });

    test('distinguishes available, booked (other user), and myBooking (current user)', () async {
      final fakeDataSource = _FakeBookingLocalDataSource();
      final repo = BookingRepositoryImpl(fakeDataSource);

      // Confirm 11:00 AM booking for current user
      await repo.confirmBooking(
        startTime: const TimeOfDay(hour: 11, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );

      final result = await repo.getSchedule();
      expect(result.isRight(), isTrue);

      result.fold((failure) => fail('Should not return failure'), (schedule) {
        // 9:00 AM is available
        final slot900 = schedule.slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 9, minute: 0),
        );
        expect(slot900.status, SlotStatus.available);

        // 10:00 AM is pre-booked by another user
        final slot1000 = schedule.slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 10, minute: 0),
        );
        expect(slot1000.status, SlotStatus.booked);

        // 11:00 AM was booked by current user
        final slot1100 = schedule.slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 11, minute: 0),
        );
        expect(slot1100.status, SlotStatus.myBooking);
      });
    });

    test('rejects booking an already booked slot (whether booked by another user or myBooking)', () async {
      final fakeDataSource = _FakeBookingLocalDataSource();
      final repo = BookingRepositoryImpl(fakeDataSource);

      // Book 11:00 AM
      await repo.confirmBooking(
        startTime: const TimeOfDay(hour: 11, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );

      // Attempt to book 11:00 AM again
      final attemptResult = await repo.confirmBooking(
        startTime: const TimeOfDay(hour: 11, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );

      expect(attemptResult.isRight(), isTrue);
      attemptResult.fold((failure) => fail('Should not return failure'), (
        schedule,
      ) {
        expect(schedule.validationResult!.isValid, isFalse);
      });
    });

    test('persists user bookings across simulated app restart', () async {
      final fakeDataSource = _FakeBookingLocalDataSource();
      final repo1 = BookingRepositoryImpl(fakeDataSource);

      // Current user confirms 11:00 AM
      await repo1.confirmBooking(
        startTime: const TimeOfDay(hour: 11, minute: 0),
        duration: BookingDuration.thirtyMinutes,
      );

      // Simulate app restart by constructing a new repository with the same data source
      final repo2 = BookingRepositoryImpl(fakeDataSource);

      final scheduleResult = await repo2.getSchedule();

      expect(scheduleResult.isRight(), isTrue);
      scheduleResult.fold((failure) => fail('Should not return failure'), (
        schedule,
      ) {
        final slot1100 = schedule.slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 11, minute: 0),
        );
        expect(slot1100.status, SlotStatus.myBooking);

        // Pre-booked slot 10:00 remains booked (belonging to another user)
        final slot1000 = schedule.slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 10, minute: 0),
        );
        expect(slot1000.status, SlotStatus.booked);
      });
    });
  });
}

class _FakeBookingLocalDataSource implements BookingLocalDataSource {
  final Map<String, List<TimeSlot>> _storage = {};
  final String _userId = 'test_user_123';

  @override
  String getCurrentUserId() => _userId;

  @override
  Future<List<TimeSlot>> getSchedule({required String currentUserId}) async {
    return _storage[currentUserId] ?? List.unmodifiable(initialSchedule);
  }

  @override
  Future<void> saveUserBooking({
    required TimeOfDay startTime,
    required BookingDuration duration,
    required String currentUserId,
  }) async {
    final base = List<TimeSlot>.from(
      _storage[currentUserId] ?? initialSchedule,
    );
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = startMins + duration.minutes;

    final updated = base.map((slot) {
      if (slot.startMinutes >= startMins && slot.startMinutes < endMins) {
        return slot.copyWith(
          status: SlotStatus.myBooking,
          bookedBy: currentUserId,
        );
      }
      return slot;
    }).toList();

    _storage[currentUserId] = updated;
  }

  @override
  Future<void> clearUserBookings() async {
    _storage.clear();
  }
}
