import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';
import 'package:booking_appointments/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// Concrete implementation of [BookingLocalDataSource] managing persistent user identity
/// and slot ownership using [SharedPreferencesService].
class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  const BookingLocalDataSourceImpl(this._sharedPreferencesService);

  final SharedPreferencesService _sharedPreferencesService;

  @override
  String getCurrentUserId() {
    return _sharedPreferencesService.getOrCreateCurrentUserId();
  }

  @override
  Future<List<TimeSlot>> getSchedule({required String currentUserId}) async {
    final rawJson = _sharedPreferencesService.getUserBookingsJson();
    if (rawJson == null || rawJson.isEmpty) {
      return List.unmodifiable(initialSchedule);
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      final userBookings = decoded.whereType<Map<String, dynamic>>().toList();

      if (userBookings.isEmpty) {
        return List.unmodifiable(initialSchedule);
      }

      return List.unmodifiable(
        initialSchedule.map((slot) {
          final slotStartMins = slot.startMinutes;

          for (final booking in userBookings) {
            final startMins = booking['startMins'] as int?;
            final endMins = booking['endMins'] as int?;
            final userId = booking['userId'] as String?;

            if (startMins != null && endMins != null) {
              if (slotStartMins >= startMins && slotStartMins < endMins) {
                final isCurrent = userId == currentUserId;
                return slot.copyWith(
                  status: isCurrent ? SlotStatus.myBooking : SlotStatus.booked,
                  bookedBy: userId ?? (isCurrent ? currentUserId : 'other'),
                );
              }
            }
          }
          return slot;
        }).toList(),
      );
    } catch (_) {
      // Corrupted JSON protection fallback
      return List.unmodifiable(initialSchedule);
    }
  }

  @override
  Future<void> saveUserBooking({
    required TimeOfDay startTime,
    required BookingDuration duration,
    required String currentUserId,
  }) async {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = startMins + duration.minutes;

    final rawJson = _sharedPreferencesService.getUserBookingsJson();
    List<Map<String, dynamic>> existingBookings = [];

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        existingBookings = decoded.whereType<Map<String, dynamic>>().toList();
      } catch (_) {
        existingBookings = [];
      }
    }

    existingBookings.add({
      'startMins': startMins,
      'endMins': endMins,
      'userId': currentUserId,
    });

    await _sharedPreferencesService.saveUserBookingsJson(
      jsonEncode(existingBookings),
    );
  }

  @override
  Future<void> clearUserBookings() async {
    await _sharedPreferencesService.clearUserBookingsJson();
  }
}
