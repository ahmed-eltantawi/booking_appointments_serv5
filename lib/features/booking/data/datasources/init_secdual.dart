import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';
import 'package:flutter/material.dart';

final List<TimeSlot> initialSchedule = [
  const TimeSlot(
    start: TimeOfDay(hour: 9, minute: 0),
    end: TimeOfDay(hour: 9, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 9, minute: 30),
    end: TimeOfDay(hour: 10, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 10, minute: 0),
    end: TimeOfDay(hour: 10, minute: 30),
    status: SlotStatus.booked,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 10, minute: 30),
    end: TimeOfDay(hour: 11, minute: 0),
    status: SlotStatus.booked,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 11, minute: 0),
    end: TimeOfDay(hour: 11, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 11, minute: 30),
    end: TimeOfDay(hour: 12, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 12, minute: 0),
    end: TimeOfDay(hour: 12, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 12, minute: 30),
    end: TimeOfDay(hour: 13, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 13, minute: 0),
    end: TimeOfDay(hour: 13, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 13, minute: 30),
    end: TimeOfDay(hour: 14, minute: 0),
    status: SlotStatus.unavailable,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 14, minute: 0),
    end: TimeOfDay(hour: 14, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 14, minute: 30),
    end: TimeOfDay(hour: 15, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 15, minute: 0),
    end: TimeOfDay(hour: 15, minute: 30),
    status: SlotStatus.booked,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 15, minute: 30),
    end: TimeOfDay(hour: 16, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 16, minute: 0),
    end: TimeOfDay(hour: 16, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 16, minute: 30),
    end: TimeOfDay(hour: 17, minute: 0),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 17, minute: 0),
    end: TimeOfDay(hour: 17, minute: 30),
    status: SlotStatus.available,
  ),
  const TimeSlot(
    start: TimeOfDay(hour: 17, minute: 30),
    end: TimeOfDay(hour: 18, minute: 0),
    status: SlotStatus.available,
  ),
];
