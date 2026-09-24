// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'حجز المواعيد';

  @override
  String get bookAppointment => 'حجز موعد';

  @override
  String get workingHours => 'ساعات العمل: 9:00 صباحاً – 6:00 مساءً';

  @override
  String get selectDuration => 'اختر المدة';

  @override
  String get duration30Min => '30 د';

  @override
  String get duration1Hour => 'ساعة';

  @override
  String get duration1Half => '١.٥ ساعة';

  @override
  String get duration2Hours => 'ساعتان';

  @override
  String get timeSlots => 'الفترات الزمنية';

  @override
  String get selectStartTimeHint => 'اضغط على فترة متاحة لاختيار وقت البدء.';

  @override
  String get legend => 'الدليل';

  @override
  String get available => 'متاح';

  @override
  String get booked => 'محجوز';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get selected => 'محدد';

  @override
  String get bookingSummary => 'ملخص الحجز';

  @override
  String get startLabel => 'البداية';

  @override
  String get endLabel => 'النهاية';

  @override
  String get durationLabel => 'المدة';

  @override
  String get noSelectionYet => 'لم يتم اختيار فترة بعد.';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get bookingSuccessful => 'تم حجز موعدك بنجاح!';

  @override
  String get errorExceedsWorkingHours =>
      'لا يمكن للحجز أن يتجاوز الساعة 6:00 مساءً.';

  @override
  String get errorContainsBookedSlot =>
      'بعض الفترات الزمنية المطلوبة محجوزة بالفعل.';

  @override
  String get errorContainsUnavailableSlot =>
      'بعض الفترات الزمنية المطلوبة غير متاحة.';

  @override
  String get errorCreatesInvalidGap =>
      'هذا الحجز سيترك فترة 30 دقيقة معزولة في الجدول.';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'افتراضي النظام';

  @override
  String get themeLight => 'المظهر الفاتح';

  @override
  String get themeDark => 'المظهر الداكن';

  @override
  String get settings => 'الإعدادات';

  @override
  String get about => 'حول التطبيق';

  @override
  String get appSubtitle => 'نظام Serv5 للحجز';

  @override
  String get copyright => '© 2026 Serv5. جميع الحقوق محفوظة.';
}
