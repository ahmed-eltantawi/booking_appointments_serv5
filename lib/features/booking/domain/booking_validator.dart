import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

///* booking_validator.dart — Core scheduling and validation logic.
///* All functions are pure (no side effects, no Flutter dependencies) and
///* independently testable. The UI layer must never reimplement these rules.

// --- Working day boundaries ---
const int kTotalSlots = 18; // Slots 0-17: 09:00 – 17:30 (each 30 min)
const int kFirstSlotIndex = 0;
const int kLastSlotIndex = 17;

//? ---------- calculateEndIndex ----------
/// Returns the inclusive index of the last slot occupied by a booking
/// starting at [startIndex] with the given [duration].
///
/// Returns [null] when the booking would extend beyond [kLastSlotIndex]
/// (i.e., the appointment end time would exceed 6:00 PM).
///
/// Example: start=16 (17:00), duration=1hr → endIndex=17 (17:30) → valid.
/// Example: start=17 (17:30), duration=1hr → endIndex=18 → null (OOB).
int? calculateEndIndex(int startIndex, BookingDuration duration) {
  final endIndex = startIndex + duration.slotCount - 1;
  if (endIndex > kLastSlotIndex) return null;
  return endIndex;
}

//? ---------- getValidStartIndexes ----------
/// Returns the slot indexes that are valid start times for [duration].
///
/// A start index is valid when ALL of the following are true:
/// 1. All required consecutive slots exist within working hours.
/// 2. Every required slot has [SlotStatus.available] status.
/// 3. Booking from this start would NOT create an isolated 30-min gap
///    (see [_createsInvalidGap] for the exact gap-rule definition).
///
/// Precondition: [slots] must be an ordered, complete list of 18 slots
/// (index 0 through 17) with no gaps in the index sequence.
List<int> getValidStartIndexes(
  List<SlotModel> slots,
  BookingDuration duration,
) {
  final validIndexes = <int>[];

  for (final slot in slots) {
    // --- Rule 1: Working-hours boundary ---
    final endIndex = calculateEndIndex(slot.index, duration);
    if (endIndex == null) continue;

    // --- Rule 2: All required slots must be available ---
    final allAvailable = slots
        .where((s) => s.index >= slot.index && s.index <= endIndex)
        .every((s) => s.status == SlotStatus.available);
    if (!allAvailable) continue;

    // --- Rule 3: Gap rule on simulated schedule ---
    final simulatedSlots = applyBooking(
      slots: slots,
      startIndex: slot.index,
      duration: duration,
    );
    if (_createsInvalidGap(simulatedSlots)) continue;

    validIndexes.add(slot.index);
  }

  return validIndexes;
}

//? ---------- validateBooking ----------
/// Validates a booking attempt against the current [slots] schedule.
///
/// Rules are evaluated in priority order. The first failing rule determines
/// the [BookingInvalidReason] returned.
///
///   1. Working-hours boundary (end index within the working day)
///   2. Booked slot collision (any required slot is already booked)
///   3. Unavailable slot collision (any required slot is unavailable)
///   4. 30-minute gap rule (the FINAL simulated schedule must not contain
///      an isolated free slot surrounded on both sides by occupied slots)
///
/// Precondition: [slots] contains no [SlotStatus.selected] entries.
/// Always pass the base schedule (before any selection overlay) to this function.
BookingValidationResult validateBooking({
  required List<SlotModel> slots,
  required int startIndex,
  required BookingDuration duration,
}) {
  // --- Rule 1: Working-hours check ---
  final endIndex = calculateEndIndex(startIndex, duration);
  if (endIndex == null) {
    return const BookingValidationResult.invalid(
      BookingInvalidReason.exceedsWorkingHours,
    );
  }

  // --- Required slot range ---
  final requiredSlots = slots.where(
    (s) => s.index >= startIndex && s.index <= endIndex,
  );

  // --- Rule 2: Booked slot check (also covers all overlap patterns) ---
  final bookedSlots =
      requiredSlots.where((s) => s.status == SlotStatus.booked).toList();
  if (bookedSlots.isNotEmpty) {
    return BookingValidationResult.invalid(
      BookingInvalidReason.containsBookedSlot,
      conflictingTimeLabels: bookedSlots.map((s) => s.timeLabel).toList(),
    );
  }

  // --- Rule 3: Unavailable slot check ---
  final unavailableSlots =
      requiredSlots.where((s) => s.status == SlotStatus.unavailable).toList();
  if (unavailableSlots.isNotEmpty) {
    return BookingValidationResult.invalid(
      BookingInvalidReason.containsUnavailableSlot,
      conflictingTimeLabels:
          unavailableSlots.map((s) => s.timeLabel).toList(),
    );
  }

  // --- Rule 4: Gap rule (evaluated on the FINAL simulated schedule) ---
  final simulatedSlots = applyBooking(
    slots: slots,
    startIndex: startIndex,
    duration: duration,
  );
  if (_createsInvalidGap(simulatedSlots)) {
    return const BookingValidationResult.invalid(
      BookingInvalidReason.createsInvalidGap,
    );
  }

  return const BookingValidationResult.valid();
}

//? ---------- applyBooking ----------
/// Returns a new, immutable slot list with the booking applied.
/// All slots in [startIndex..endIndex] (inclusive) become [SlotStatus.booked].
///
/// Does NOT validate the booking. Always call [validateBooking] first.
/// The original [slots] list is never mutated.
List<SlotModel> applyBooking({
  required List<SlotModel> slots,
  required int startIndex,
  required BookingDuration duration,
}) {
  final endIndex = calculateEndIndex(startIndex, duration)!;
  return List.unmodifiable(
    slots.map((slot) {
      if (slot.index >= startIndex && slot.index <= endIndex) {
        return slot.copyWith(status: SlotStatus.booked);
      }
      return slot;
    }).toList(),
  );
}

//? ---------- _createsInvalidGap (private) ----------
/// Returns [true] if [simulatedSlots] contains at least one **isolated free slot**:
/// a slot that is [SlotStatus.available] AND has both its immediate predecessor
/// AND immediate successor occupied.
///
/// **Occupation definition**: [SlotStatus.booked] OR [SlotStatus.unavailable].
/// Rationale: an unavailable slot is unusable regardless of context, so a free
/// slot surrounded by an unavailable slot and a booked slot is equally unusable.
/// Change [_isOccupied] to revise this assumption without touching other rules.
///
/// **Boundary exclusion**: slot [kFirstSlotIndex] and slot [kLastSlotIndex] are
/// never evaluated — they have only one neighbor and therefore cannot be
/// "surrounded." A free slot at the edge of the day is not a gap.
///
/// Precondition: [simulatedSlots] is an ordered, complete 18-element list
/// (indexes 0–17) so that list position equals slot index.
bool _createsInvalidGap(List<SlotModel> simulatedSlots) {
  // Evaluate only inner slots — positions 1 through 16 (inclusive).
  for (var i = kFirstSlotIndex + 1; i < kLastSlotIndex; i++) {
    // The list is accessed by position (i), which equals slot.index because
    // the schedule is always a complete, ordered 18-element list.
    final current = simulatedSlots[i];
    if (current.status != SlotStatus.available) continue;

    final leftNeighbor = simulatedSlots[i - 1];
    final rightNeighbor = simulatedSlots[i + 1];

    if (_isOccupied(leftNeighbor.status) && _isOccupied(rightNeighbor.status)) {
      return true; // Isolated 30-minute gap detected.
    }
  }
  return false;
}

/// Returns [true] when [status] counts as occupied for gap-rule purposes.
/// Currently: [SlotStatus.booked] and [SlotStatus.unavailable] are both occupied.
bool _isOccupied(SlotStatus status) {
  return status == SlotStatus.booked || status == SlotStatus.unavailable;
}
