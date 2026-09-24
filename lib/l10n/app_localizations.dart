import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application title shown in the app bar and system.
  ///
  /// In en, this message translates to:
  /// **'Appointment Booking'**
  String get appTitle;

  /// Main screen heading.
  ///
  /// In en, this message translates to:
  /// **'Book an Appointment'**
  String get bookAppointment;

  /// Displayed below the main heading as context.
  ///
  /// In en, this message translates to:
  /// **'Working hours: 9:00 AM – 6:00 PM'**
  String get workingHours;

  /// Label above the duration chip row.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// Label for the 30-minute booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get duration30Min;

  /// Label for the 1-hour booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'1 hr'**
  String get duration1Hour;

  /// Label for the 1.5-hour booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'1.5 hr'**
  String get duration1Half;

  /// Label for the 2-hour booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'2 hr'**
  String get duration2Hours;

  /// Label above the time-slot grid.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get timeSlots;

  /// Hint text shown below the time slots label.
  ///
  /// In en, this message translates to:
  /// **'Tap an available slot to choose a start time.'**
  String get selectStartTimeHint;

  /// Label above the slot legend row.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Section heading for the booking summary card.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// Label for the booking start time row.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// Label for the booking end time row.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// Label for the booking duration row.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// Shown in summary when no start time is selected.
  ///
  /// In en, this message translates to:
  /// **'No time slot selected yet.'**
  String get noSelectionYet;

  /// Reset button label.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Confirm booking button label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Success message shown after a booking is confirmed.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been booked successfully!'**
  String get bookingSuccessful;

  /// Validation error when booking exceeds working hours.
  ///
  /// In en, this message translates to:
  /// **'Booking cannot extend past 6:00 PM.'**
  String get errorExceedsWorkingHours;

  /// Validation error when required slots overlap an existing booking.
  ///
  /// In en, this message translates to:
  /// **'One or more required time slots are already booked.'**
  String get errorContainsBookedSlot;

  /// Validation error when required slots are marked unavailable.
  ///
  /// In en, this message translates to:
  /// **'One or more required time slots are unavailable.'**
  String get errorContainsUnavailableSlot;

  /// Validation error when the booking creates a forbidden isolated gap.
  ///
  /// In en, this message translates to:
  /// **'This booking would leave an isolated 30-minute gap in the schedule.'**
  String get errorCreatesInvalidGap;

  /// Label for theme setting option.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Label for system default theme option.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// Label for light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// Label for dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
