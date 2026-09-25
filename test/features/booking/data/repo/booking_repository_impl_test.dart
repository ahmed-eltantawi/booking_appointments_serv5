import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      result.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(schedule.slots.length, 18);
          expect(schedule.selectedDuration, BookingDuration.thirtyMinutes);
          expect(schedule.selectedStart, isNull);
        },
      );
    });

    test('selectStartTime updates schedule with selectedStart', () async {
      final result = await repository.selectStartTime(
        const TimeOfDay(hour: 9, minute: 0),
        BookingDuration.thirtyMinutes,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(schedule.selectedStart, const TimeOfDay(hour: 9, minute: 0));
        },
      );
    });

    test('confirmBooking applies booking to base schedule when valid', () async {
      await repository.selectStartTime(
        const TimeOfDay(hour: 9, minute: 30),
        BookingDuration.thirtyMinutes,
      );
      final confirmResult = await repository.confirmBooking(
        startTime: const TimeOfDay(hour: 9, minute: 30),
        duration: BookingDuration.thirtyMinutes,
      );

      expect(confirmResult.isRight(), isTrue);
      confirmResult.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(
            schedule.slots
                .firstWhere((s) => s.start == const TimeOfDay(hour: 9, minute: 30))
                .status,
            SlotStatus.booked,
          );
          expect(schedule.selectedStart, isNull);
        },
      );
    });

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
      resetResult.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(
            schedule.slots
                .firstWhere((s) => s.start == const TimeOfDay(hour: 9, minute: 30))
                .status,
            SlotStatus.available,
          );
        },
      );
    });
  });
}
