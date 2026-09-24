// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Appointment Booking';

  @override
  String get bookAppointment => 'Book an Appointment';

  @override
  String get workingHours => 'Working hours: 9:00 AM – 6:00 PM';

  @override
  String get selectDuration => 'Select Duration';

  @override
  String get duration30Min => '30 min';

  @override
  String get duration1Hour => '1 hr';

  @override
  String get duration1Half => '1.5 hr';

  @override
  String get duration2Hours => '2 hr';

  @override
  String get timeSlots => 'Time Slots';

  @override
  String get selectStartTimeHint =>
      'Tap an available slot to choose a start time.';

  @override
  String get legend => 'Legend';

  @override
  String get available => 'Available';

  @override
  String get booked => 'Booked';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get selected => 'Selected';

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get durationLabel => 'Duration';

  @override
  String get noSelectionYet => 'No time slot selected yet.';

  @override
  String get reset => 'Reset';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get bookingSuccessful =>
      'Your appointment has been booked successfully!';

  @override
  String get errorExceedsWorkingHours => 'Booking cannot extend past 6:00 PM.';

  @override
  String get errorContainsBookedSlot =>
      'One or more required time slots are already booked.';

  @override
  String get errorContainsUnavailableSlot =>
      'One or more required time slots are unavailable.';

  @override
  String get errorCreatesInvalidGap =>
      'This booking would leave an isolated 30-minute gap in the schedule.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get about => 'About';

  @override
  String get aboutAppDescription =>
      'Appointment Booking application built for scheduling appointments with real-time validation rules.';

  @override
  String get close => 'Close';

  @override
  String slotFeedbackBooked(String time) {
    return '$time is already booked.';
  }

  @override
  String slotFeedbackUnavailable(String time) {
    return '$time is currently unavailable.';
  }

  @override
  String slotFeedbackExceedsHours(String time, String duration) {
    return 'A $duration booking starting at $time would extend past 6:00 PM.';
  }

  @override
  String slotFeedbackOverlap(String time, String duration) {
    return 'A $duration booking starting at $time overlaps with an existing booking.';
  }

  @override
  String slotFeedbackContainsUnavailable(String time, String duration) {
    return 'A $duration booking starting at $time includes unavailable slots.';
  }

  @override
  String slotFeedbackCreatesGap(String time) {
    return 'A booking starting at $time would leave an unusable 30-minute gap.';
  }
}
