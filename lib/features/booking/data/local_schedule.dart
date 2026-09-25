import 'package:booking_appointments/features/booking/domain/slot_model.dart';

///* initialSchedule — the seed schedule loaded when the app starts or resets.
///* Contains a realistic mix of booked, unavailable, and available slots
///* designed to exercise all validation rules and edge cases.
///
/// Index → Time mapping (each slot = 30 minutes, day starts at 09:00 AM):
///   0 = 09:00 AM   6 = 12:00 PM  12 = 03:00 PM
///   1 = 09:30 AM   7 = 12:30 PM  13 = 03:30 PM
///   2 = 10:00 AM   8 = 01:00 PM  14 = 04:00 PM
///   3 = 10:30 AM   9 = 01:30 PM  15 = 04:30 PM
///   4 = 11:00 AM  10 = 02:00 PM  16 = 05:00 PM
///   5 = 11:30 AM  11 = 02:30 PM  17 = 05:30 PM
///
/// Edge cases covered by this dataset:
///   • Slots 2-3 booked → tests overlap and consecutive-slot rules.
///   • Slot 9 unavailable → tests unavailable-slot rejection.
///   • Slot 12 booked → gap-trigger: booking slot 10 (30 min) would leave
///     slot 11 isolated between newly-booked(10) and booked(12).
///   • Slot 16 available → 16+1hr=valid (ends 18:00); 16+2hr=invalid (ends 19:00).
///   • Slot 17 available → 17+30min=valid (ends 18:00); 17+1hr=invalid (ends 18:30).
const List<SlotModel> initialSchedule = [
  SlotModel(index: 0, status: SlotStatus.available), // 09:00 AM
  SlotModel(index: 1, status: SlotStatus.available), // 09:30 AM
  SlotModel(index: 2, status: SlotStatus.booked), // 10:00 AM — pre-booked
  SlotModel(index: 3, status: SlotStatus.booked), // 10:30 AM — pre-booked
  SlotModel(index: 4, status: SlotStatus.available), // 11:00 AM
  SlotModel(index: 5, status: SlotStatus.available), // 11:30 AM
  SlotModel(index: 6, status: SlotStatus.available), // 12:00 PM
  SlotModel(index: 7, status: SlotStatus.available), // 12:30 PM
  SlotModel(index: 8, status: SlotStatus.available), // 01:00 PM
  SlotModel(index: 9, status: SlotStatus.unavailable), // 01:30 PM — blocked
  SlotModel(
    index: 10,
    status: SlotStatus.available,
  ), // 02:00 PM — gap trigger (see above)
  SlotModel(index: 11, status: SlotStatus.available), // 02:30 PM — would be gap
  SlotModel(
    index: 12,
    status: SlotStatus.booked,
  ), // 03:00 PM — pre-booked (gap anchor)
  SlotModel(index: 13, status: SlotStatus.available), // 03:30 PM
  SlotModel(index: 14, status: SlotStatus.available), // 04:00 PM
  SlotModel(index: 15, status: SlotStatus.available), // 04:30 PM
  SlotModel(
    index: 16,
    status: SlotStatus.available,
  ), // 05:00 PM — end-of-day boundary
  SlotModel(
    index: 17,
    status: SlotStatus.available,
  ), // 05:30 PM — end-of-day boundary
];
