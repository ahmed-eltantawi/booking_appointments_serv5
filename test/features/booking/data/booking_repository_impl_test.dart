import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/features/booking/data/booking_repository_impl.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

void main() {
  late BookingRepositoryImpl repository;

  setUp(() {
    repository = BookingRepositoryImpl();
  });

  group('BookingRepositoryImpl Unit Tests', () {
    test('getSchedule returns initial schedule successfully', () async {
      final result = await repository.getSchedule();

      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(schedule.slots.length, 18);
          expect(schedule.selectedDuration, BookingDuration.thirtyMinutes);
          expect(schedule.selectedStartIndex, isNull);
        },
      );
    });

    test('selectStartTime updates schedule with selection overlay', () async {
      final result = await repository.selectStartTime(0, BookingDuration.thirtyMinutes);

      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(schedule.selectedStartIndex, 0);
          expect(schedule.selectedEndIndex, 0);
          expect(schedule.slots[0].status, SlotStatus.selected);
        },
      );
    });

    test('confirmBooking applies booking to base schedule when valid', () async {
      await repository.selectStartTime(1, BookingDuration.thirtyMinutes);
      final confirmResult = await repository.confirmBooking(
        startIndex: 1,
        duration: BookingDuration.thirtyMinutes,
      );

      expect(confirmResult.isRight, isTrue);
      confirmResult.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(schedule.slots[1].status, SlotStatus.booked);
          expect(schedule.selectedStartIndex, isNull);
        },
      );
    });

    test('resetSchedule restores initial seed slots', () async {
      await repository.selectStartTime(1, BookingDuration.thirtyMinutes);
      await repository.confirmBooking(
        startIndex: 1,
        duration: BookingDuration.thirtyMinutes,
      );

      final resetResult = await repository.resetSchedule();

      expect(resetResult.isRight, isTrue);
      resetResult.fold(
        (failure) => fail('Should not return failure'),
        (schedule) {
          expect(schedule.slots[1].status, SlotStatus.available);
        },
      );
    });
  });
}
