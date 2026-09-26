import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/core/cache/shared_preferences_helper.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';
import 'package:booking_appointments/features/booking/data/datasources/booking_local_datasource_impl.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late SharedPreferencesHelper helper;
  late SharedPreferencesService service;
  late BookingLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    helper = SharedPreferencesHelper(sharedPreferences);
    service = SharedPreferencesService(helper);
    dataSource = BookingLocalDataSourceImpl(service);
  });

  group('BookingLocalDataSourceImpl Unit Tests', () {
    test('getCurrentUserId generates stable ID across calls', () {
      final id1 = dataSource.getCurrentUserId();
      final id2 = dataSource.getCurrentUserId();

      expect(id1, isNotEmpty);
      expect(id1, equals(id2));
    });

    test(
      'getSchedule returns initial seed schedule when cache is empty',
      () async {
        final userId = dataSource.getCurrentUserId();
        final slots = await dataSource.getSchedule(currentUserId: userId);

        expect(slots.length, 18);
        // Pre-booked slots at 10:00 AM remain SlotStatus.booked (other user)
        final slot1000 = slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 10, minute: 0),
        );
        expect(slot1000.status, SlotStatus.booked);
      },
    );

    test(
      'saveUserBooking persists booking and getSchedule returns myBooking',
      () async {
        final userId = dataSource.getCurrentUserId();

        await dataSource.saveUserBooking(
          startTime: const TimeOfDay(hour: 11, minute: 0),
          duration: BookingDuration.oneHour,
          currentUserId: userId,
        );

        final slots = await dataSource.getSchedule(currentUserId: userId);

        final slot1100 = slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 11, minute: 0),
        );
        final slot1130 = slots.firstWhere(
          (s) => s.start == const TimeOfDay(hour: 11, minute: 30),
        );

        expect(slot1100.status, SlotStatus.myBooking);
        expect(slot1100.bookedBy, userId);
        expect(slot1130.status, SlotStatus.myBooking);
        expect(slot1130.bookedBy, userId);
      },
    );

    test('handles corrupted JSON in cache safely without crashing', () async {
      final userId = dataSource.getCurrentUserId();
      await service.saveUserBookingsJson('{corrupted_json_string}');

      final slots = await dataSource.getSchedule(currentUserId: userId);
      expect(slots.length, 18);
    });

    test('clearUserBookings removes saved user bookings', () async {
      final userId = dataSource.getCurrentUserId();

      await dataSource.saveUserBooking(
        startTime: const TimeOfDay(hour: 11, minute: 0),
        duration: BookingDuration.thirtyMinutes,
        currentUserId: userId,
      );

      await dataSource.clearUserBookings();

      final slots = await dataSource.getSchedule(currentUserId: userId);
      final slot1100 = slots.firstWhere(
        (s) => s.start == const TimeOfDay(hour: 11, minute: 0),
      );

      expect(slot1100.status, SlotStatus.available);
    });
  });
}
