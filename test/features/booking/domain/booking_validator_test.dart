import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:booking_appointments/features/booking/data/booking_repository_impl.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/booking_validator.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

// =============================================================================
// Test schedule builder helpers
// =============================================================================

List<SlotModel> _allAvailable() =>
    List.generate(kTotalSlots, (i) => SlotModel(index: i, status: SlotStatus.available));

List<SlotModel> _scheduleWith({
  List<int> booked = const [],
  List<int> unavailable = const [],
}) {
  return List.generate(kTotalSlots, (i) {
    if (booked.contains(i)) return SlotModel(index: i, status: SlotStatus.booked);
    if (unavailable.contains(i)) return SlotModel(index: i, status: SlotStatus.unavailable);
    return SlotModel(index: i, status: SlotStatus.available);
  });
}

void main() {
  // ===========================================================================
  // Group 1 — calculateEndIndex
  // ===========================================================================
  group('calculateEndIndex', () {
    // T01: 30 min from slot 0 → occupies only slot 0
    test('T01: 30min from slot 0 → endIndex 0', () {
      expect(calculateEndIndex(0, BookingDuration.thirtyMinutes), 0);
    });

    // T02: 1 hour from slot 0 → occupies slots 0 and 1
    test('T02: 1hr from slot 0 → endIndex 1', () {
      expect(calculateEndIndex(0, BookingDuration.oneHour), 1);
    });

    // T03: 2 hours from slot 14 → endIndex = 14+3 = 17 (boundary)
    test('T03: 2hr from slot 14 → endIndex 17 (valid boundary)', () {
      expect(calculateEndIndex(14, BookingDuration.twoHours), 17);
    });

    // T04: 30min from slot 17 → endIndex = 17 (last valid slot)
    test('T04: 30min from slot 17 → endIndex 17', () {
      expect(calculateEndIndex(17, BookingDuration.thirtyMinutes), 17);
    });

    // T05: 1hr from slot 17 → endIndex = 18 → OOB → null
    test('T05: 1hr from slot 17 → null (OOB)', () {
      expect(calculateEndIndex(17, BookingDuration.oneHour), isNull);
    });

    // T06: 2hr from slot 15 → endIndex = 18 → null
    test('T06: 2hr from slot 15 → null (OOB)', () {
      expect(calculateEndIndex(15, BookingDuration.twoHours), isNull);
    });

    // T07: 1.5hr from slot 16 → endIndex = 18 → null
    test('T07: 1.5hr from slot 16 → null (OOB)', () {
      expect(calculateEndIndex(16, BookingDuration.oneHalfHour), isNull);
    });

    // T08: 1hr from slot 16 → endIndex = 17 (valid)
    test('T08: 1hr from slot 16 → endIndex 17 (valid)', () {
      expect(calculateEndIndex(16, BookingDuration.oneHour), 17);
    });
  });

  // ===========================================================================
  // Group 2 — getValidStartIndexes
  // ===========================================================================
  group('getValidStartIndexes', () {
    // T09: all available, 30min → all 18 slots are valid
    test('T09: all available, 30min → 18 valid starts', () {
      final result = getValidStartIndexes(_allAvailable(), BookingDuration.thirtyMinutes);
      expect(result.length, 18);
      expect(result, List.generate(18, (i) => i));
    });

    // T10: all available, 2hr → slots 0-14 valid (15,16,17 OOB for 2hr)
    test('T10: all available, 2hr → only slots 0-14 valid', () {
      final result = getValidStartIndexes(_allAvailable(), BookingDuration.twoHours);
      expect(result, List.generate(15, (i) => i)); // 0..14
      expect(result.contains(15), isFalse);
    });

    // T11: slot 5 booked, 30min → slot 5 excluded
    test('T11: slot 5 booked, 30min → slot 5 not a valid start', () {
      final slots = _scheduleWith(booked: [5]);
      final result = getValidStartIndexes(slots, BookingDuration.thirtyMinutes);
      expect(result.contains(5), isFalse);
    });

    // T12: slots 5-6 booked, 1hr → slots whose range intersects 5 or 6 excluded
    test('T12: slots 5-6 booked, 1hr → starts 4-6 excluded', () {
      final slots = _scheduleWith(booked: [5, 6]);
      final result = getValidStartIndexes(slots, BookingDuration.oneHour);
      // starts 4 (range 4-5), 5 (range 5-6), 6 (range 6-7) all invalid
      expect(result.contains(4), isFalse);
      expect(result.contains(5), isFalse);
      expect(result.contains(6), isFalse);
      expect(result.contains(3), isTrue); // range 3-4 — both available
      expect(result.contains(7), isTrue); // range 7-8 — both available
    });

    // T13: gap-rule filtering — slot 10,12 booked → slot 9 excluded (booking 9
    // would leave 11 isolated between booked 10 and booked 12)
    test('T13: slots 10,12 booked, 30min → slot 9 excluded by gap rule', () {
      final slots = _scheduleWith(booked: [10, 12]);
      final result = getValidStartIndexes(slots, BookingDuration.thirtyMinutes);
      expect(result.contains(9), isFalse);
    });

    // T14: gap-rule — slot 11 is valid (fills the gap between 10 and 12)
    test('T14: slots 10,12 booked, 30min → slot 11 IS valid (fills gap)', () {
      final slots = _scheduleWith(booked: [10, 12]);
      final result = getValidStartIndexes(slots, BookingDuration.thirtyMinutes);
      expect(result.contains(11), isTrue);
    });
  });

  // ===========================================================================
  // Group 3 — validateBooking: working-hours rule
  // ===========================================================================
  group('validateBooking — working hours', () {
    // T15: start=17, 30min → valid (ends at slot 17, = 06:00 PM)
    test('T15: 30min from slot 17 → valid (boundary)', () {
      final result = validateBooking(
        slots: _allAvailable(),
        startIndex: 17,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    // T16: start=17, 1hr → invalid (exceedsWorkingHours)
    test('T16: 1hr from slot 17 → exceedsWorkingHours', () {
      final result = validateBooking(
        slots: _allAvailable(),
        startIndex: 17,
        duration: BookingDuration.oneHour,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.exceedsWorkingHours);
    });

    // T17: start=16, 2hr → invalid (endIndex=19 > 17)
    test('T17: 2hr from slot 16 → exceedsWorkingHours', () {
      final result = validateBooking(
        slots: _allAvailable(),
        startIndex: 16,
        duration: BookingDuration.twoHours,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.exceedsWorkingHours);
    });
  });

  // ===========================================================================
  // Group 4 — validateBooking: booked slot rule
  // ===========================================================================
  group('validateBooking — booked slot', () {
    // T18: start slot itself is booked
    test('T18: start slot booked → containsBookedSlot', () {
      final slots = _scheduleWith(booked: [5]);
      final result = validateBooking(
        slots: slots,
        startIndex: 5,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsBookedSlot);
    });

    // T19: booked slot in the MIDDLE of a 2hr range
    test('T19: booked slot mid-range → containsBookedSlot', () {
      final slots = _scheduleWith(booked: [6]); // range 4-7 for 2hr from 4
      final result = validateBooking(
        slots: slots,
        startIndex: 4,
        duration: BookingDuration.twoHours,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsBookedSlot);
    });

    // T20: booked slot immediately AFTER range → valid (not in range)
    test('T20: booked slot just after range → valid', () {
      final slots = _scheduleWith(booked: [6]); // range 0-3 for 2hr from 0, leaving 4,5 free
      final result = validateBooking(
        slots: slots,
        startIndex: 0,
        duration: BookingDuration.twoHours,
      );
      expect(result.isValid, isTrue);
    });
  });

  // ===========================================================================
  // Group 5 — validateBooking: unavailable slot rule
  // ===========================================================================
  group('validateBooking — unavailable slot', () {
    // T21: unavailable slot is the target start
    test('T21: start slot unavailable → containsUnavailableSlot', () {
      final slots = _scheduleWith(unavailable: [8]);
      final result = validateBooking(
        slots: slots,
        startIndex: 8,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsUnavailableSlot);
    });

    // T22: unavailable slot within a 1hr range
    test('T22: unavailable slot in range → containsUnavailableSlot', () {
      final slots = _scheduleWith(unavailable: [3]); // range 2-3 for 1hr from 2
      final result = validateBooking(
        slots: slots,
        startIndex: 2,
        duration: BookingDuration.oneHour,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsUnavailableSlot);
    });

    // T23: booked takes priority over unavailable when both apply
    // (booked check runs before unavailable check)
    test('T23: booked + unavailable both in range → containsBookedSlot wins', () {
      final slots = _scheduleWith(booked: [2], unavailable: [3]);
      final result = validateBooking(
        slots: slots,
        startIndex: 2,
        duration: BookingDuration.oneHour, // range 2-3
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.containsBookedSlot);
    });
  });

  // ===========================================================================
  // Group 6 — validateBooking: gap rule
  // ===========================================================================
  group('validateBooking — gap rule', () {
    // T24: No gap — two adjacent booked slots with a new booking extending the
    // block. Pattern: [prev-booked]→[new-booked][new-booked]→[avail]
    test('T24: no gap when booking fills a contiguous block', () {
      // Slots 3,4 booked; book slot 5 (30min) → no isolated slot created
      final slots = _scheduleWith(booked: [3, 4]);
      final result = validateBooking(
        slots: slots,
        startIndex: 5,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    // T25: Gap created — BOOKED→FREE→BOOKED pattern after simulation
    // Slots 5,7 booked; booking slot 4 (30min) → slot 6 becomes isolated
    // After: 4-booked, 5-booked, 6-available, 7-booked → 6 is surrounded
    test('T25: gap created — isolated free slot between new and existing booking', () {
      final slots = _scheduleWith(booked: [5, 7]);
      final result = validateBooking(
        slots: slots,
        startIndex: 4,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.createsInvalidGap);
    });

    // T26: BOOKED→FREE→BOOKED but with TWO free slots → NOT a gap (two consecutive)
    // Slots 5,8 booked; booking slot 4 (30min) → slots 6,7 are free — not isolated
    test('T26: two consecutive free slots between bookings → not a gap', () {
      final slots = _scheduleWith(booked: [5, 8]);
      final result = validateBooking(
        slots: slots,
        startIndex: 4,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    // T27: Unavailable counts as occupied in gap check
    // Slots 3 booked; slot 5 unavailable; book slot 2 (30min) → slot 4 isolated
    // After: 2-booked(new), 3-booked, 4-available, 5-unavailable → 4 is surrounded
    test('T27: unavailable neighbor triggers gap rule (counts as occupied)', () {
      final slots = _scheduleWith(booked: [3], unavailable: [5]);
      final result = validateBooking(
        slots: slots,
        startIndex: 2,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.createsInvalidGap);
    });

    // T28: Filling a gap is valid — multi-slot booking that covers the free slot
    // Slots 3,6 booked; book slot 4 (1hr = slots 4,5) → fills the gap
    // After: 3-booked, 4-booked(new), 5-booked(new), 6-booked → no free slot
    test('T28: multi-slot booking fills an existing gap → valid', () {
      final slots = _scheduleWith(booked: [3, 6]);
      final result = validateBooking(
        slots: slots,
        startIndex: 4,
        duration: BookingDuration.oneHour, // occupies slots 4,5
      );
      expect(result.isValid, isTrue);
    });

    // T29: Boundary slot (index 0) — free at position 0 cannot be a gap
    // (no left neighbor to surround it)
    test('T29: slot 0 free, slot 1 booked → boundary exclusion, no gap', () {
      final slots = _scheduleWith(booked: [1]);
      // Slot 0 is free. Left neighbor doesn't exist. Cannot be a gap.
      // Book slot 4 (arbitrary) — slots 2,3 free → no gap created
      final result = validateBooking(
        slots: slots,
        startIndex: 4,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    // T30: Boundary slot (index 17) — free at position 17 cannot be a gap
    test('T30: slot 17 free, slot 16 booked → boundary exclusion, no gap', () {
      final slots = _scheduleWith(booked: [16]);
      // Book slot 14: after → 14-booked, 15-available, 16-booked
      // Slot 15 is surrounded → gap! But slot 17 at boundary is NOT evaluated.
      final result = validateBooking(
        slots: slots,
        startIndex: 14,
        duration: BookingDuration.thirtyMinutes,
      );
      // Slot 15 IS isolated (16-booked on right, 14-newly-booked on left) → gap
      expect(result.isValid, isFalse);
      expect(result.reason, BookingInvalidReason.createsInvalidGap);
    });
  });

  // ===========================================================================
  // Group 7 — applyBooking
  // ===========================================================================
  group('applyBooking', () {
    // T31: 30min booking marks exactly one slot as booked
    test('T31: 30min from slot 0 → only slot 0 becomes booked', () {
      final result = applyBooking(
        slots: _allAvailable(),
        startIndex: 0,
        duration: BookingDuration.thirtyMinutes,
      );
      expect(result[0].status, SlotStatus.booked);
      expect(result[1].status, SlotStatus.available);
    });

    // T32: 2hr booking marks exactly 4 slots as booked
    test('T32: 2hr from slot 10 → slots 10-13 booked, others unchanged', () {
      final result = applyBooking(
        slots: _allAvailable(),
        startIndex: 10,
        duration: BookingDuration.twoHours,
      );
      for (var i = 10; i <= 13; i++) {
        expect(result[i].status, SlotStatus.booked, reason: 'slot $i should be booked');
      }
      expect(result[9].status, SlotStatus.available);
      expect(result[14].status, SlotStatus.available);
    });

    // T33: Original list is not mutated
    test('T33: applyBooking does not mutate the original list', () {
      final original = _allAvailable();
      applyBooking(
        slots: original,
        startIndex: 5,
        duration: BookingDuration.oneHour,
      );
      expect(original[5].status, SlotStatus.available); // unchanged
    });
  });

  // ===========================================================================
  // Group 8 — slotIndexToTimeLabel
  // ===========================================================================
  group('slotIndexToTimeLabel', () {
    // T34: index 0 = 09:00 AM
    test('T34: index 0 → "9:00 AM"', () {
      expect(slotIndexToTimeLabel(0), '9:00 AM');
    });

    // T35: index 5 = 11:30 AM
    test('T35: index 5 → "11:30 AM"', () {
      expect(slotIndexToTimeLabel(5), '11:30 AM');
    });

    // T36: index 6 = 12:00 PM (noon)
    test('T36: index 6 → "12:00 PM"', () {
      expect(slotIndexToTimeLabel(6), '12:00 PM');
    });

    // T37: index 17 = 05:30 PM (last slot start)
    test('T37: index 17 → "5:30 PM"', () {
      expect(slotIndexToTimeLabel(17), '5:30 PM');
    });

    // T38: index 18 = 06:00 PM (end of working day — used for booking end time)
    test('T38: index 18 → "6:00 PM" (end of working day)', () {
      expect(slotIndexToTimeLabel(18), '6:00 PM');
    });
  });

  // ===========================================================================
  // Group 9 — BookingCubit
  // ===========================================================================
  group('BookingCubit', () {
    late BookingRepositoryImpl repository;

    setUp(() {
      repository = BookingRepositoryImpl();
    });

    // T39: initialize emits BookingLoading then BookingSuccess
    blocTest<BookingCubit, BookingState>(
      'T39: initialize() → emits [BookingLoading, BookingSuccess]',
      build: () => BookingCubit(repository),
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const BookingLoading(),
        isA<BookingSuccess>()
            .having((s) => s.schedule.selectedStartIndex, 'selectedStartIndex', isNull),
      ],
    );

    // T40: selectStartTime emits BookingSuccess with selection
    blocTest<BookingCubit, BookingState>(
      'T40: selectStartTime(0) after init → emits BookingSuccess(selected)',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(0);
      },
      expect: () => [
        const BookingLoading(),
        isA<BookingSuccess>(),
        isA<BookingSuccess>()
            .having((s) => s.schedule.selectedStartIndex, 'selectedStartIndex', 0),
      ],
    );

    // T41: confirmBooking on a valid selection → emits BookingConfirmed, schedule updated
    blocTest<BookingCubit, BookingState>(
      'T41: confirmBooking() with valid selection → emits BookingConfirmed',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(1); // slot 1 is valid in seed schedule
        await cubit.confirmBooking();
      },
      expect: () => [
        const BookingLoading(),
        isA<BookingSuccess>(),
        isA<BookingSuccess>(),
        isA<BookingConfirmed>(),
      ],
      verify: (cubit) {
        final state = cubit.state as BookingConfirmed;
        expect(state.schedule.slots[1].status, SlotStatus.booked);
      },
    );

    // T42: reset restores original schedule after a confirmed booking
    blocTest<BookingCubit, BookingState>(
      'T42: reset() after confirm → restores original schedule',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(0);
        await cubit.confirmBooking();
        await cubit.reset();
      },
      verify: (cubit) {
        final state = cubit.state as BookingSuccess;
        expect(state.schedule.slots[0].status, SlotStatus.available); // restored
        expect(state.schedule.slots[2].status, SlotStatus.booked);    // original intact
      },
    );

    // T43: confirmBooking without selection → no state change
    blocTest<BookingCubit, BookingState>(
      'T43: confirmBooking without selection → no state change',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.confirmBooking(); // no start selected → no-op
      },
      expect: () => [
        const BookingLoading(),
        isA<BookingSuccess>(),
      ],
    );

    // T44: selectDuration clears selection when new duration makes start OOB
    blocTest<BookingCubit, BookingState>(
      'T44: selectDuration to 2hr when start=16 → clears selection',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(16); // valid for 30min
        await cubit.selectDuration(BookingDuration.twoHours); // OOB
      },
      verify: (cubit) {
        final state = cubit.state as BookingSuccess;
        expect(state.schedule.selectedStartIndex, isNull);
        expect(state.schedule.selectedDuration, BookingDuration.twoHours);
      },
    );

    // T45: selectDuration preserves selection when start is still valid
    blocTest<BookingCubit, BookingState>(
      'T45: selectDuration from 30min to 1hr when start=13 → preserves selection',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectStartTime(13);
        await cubit.selectDuration(BookingDuration.oneHour);
      },
      verify: (cubit) {
        final state = cubit.state as BookingSuccess;
        expect(state.schedule.selectedStartIndex, 13);
        expect(state.schedule.selectedEndIndex, 14);
        expect(state.schedule.selectedDuration, BookingDuration.oneHour);
      },
    );

    // T46: validateBooking for 1.5hr from slot 15 → ends at slot 17 (06:00 PM) → valid
    test('T46: 1.5hr from slot 15 → valid boundary at 18:00', () {
      final result = validateBooking(
        slots: _allAvailable(),
        startIndex: 15,
        duration: BookingDuration.oneHalfHour,
      );
      expect(result.isValid, isTrue);
    });

    // T47: reset after invalid selection → clears error and restores success state
    blocTest<BookingCubit, BookingState>(
      'T47: reset() after invalid selection → clears error and emits success state',
      build: () => BookingCubit(repository),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.handleSlotTap(2); // slot 2 is booked
        await cubit.reset();
      },
      verify: (cubit) {
        final state = cubit.state as BookingSuccess;
        expect(state.schedule.selectedStartIndex, isNull);
        expect(state.schedule.validationResult, isNull);
      },
    );
  });
}
