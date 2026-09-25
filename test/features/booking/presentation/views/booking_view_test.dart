import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/services/services_locator.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/app_drawer_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_summary_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell_widget.dart';
import 'package:booking_appointments/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    await setupServiceLocator();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget createWidgetToTest() {
    return const BookingApp();
  }

  group('BookingView UI Integration Tests', () {
    testWidgets('renders all core UI sections and title', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      expect(find.text('Book an Appointment'), findsNWidgets(2));
      expect(find.text('Working hours: 9:00 AM – 6:00 PM'), findsOneWidget);
      expect(find.text('Select Duration'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('1 hr'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('allows duration selection change', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('1 hr'));
      await tester.pumpAndSettle();

      expect(find.text('1 hr'), findsOneWidget);
    });

    testWidgets('tapping valid time slot selects it and shows summary widget', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final slotFinder = find.text('9:30 AM');
      expect(slotFinder, findsOneWidget);

      await tester.tap(slotFinder);
      await tester.pumpAndSettle();

      expect(find.text('Booking Summary'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('tapping booked slot displays contextual booked snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final bookedSlotFinder = find.text('10:00 AM');
      expect(bookedSlotFinder, findsOneWidget);

      await tester.ensureVisible(bookedSlotFinder);
      await tester.tap(bookedSlotFinder);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('One or more required time slots are already booked.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping unavailable slot displays contextual unavailable snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final unavailableSlotFinder = find.text('1:30 PM');
      expect(unavailableSlotFinder, findsOneWidget);

      await tester.ensureVisible(unavailableSlotFinder);
      await tester.tap(unavailableSlotFinder);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('One or more required time slots are unavailable.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('confirming booking updates schedule and shows confirmation snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('9:30 AM'));
      await tester.pumpAndSettle();

      final confirmBtn = find.text('Confirm Booking');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.text('Your appointment has been booked successfully!'), findsOneWidget);
    });

    testWidgets('configures AppDrawerWidget on Scaffold drawer', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isA<AppDrawerWidget>());
    });

    testWidgets('allows dynamic language switching via SettingsCubit', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      expect(find.text('Book an Appointment'), findsNWidgets(2));

      GetIt.I<SettingsCubit>().setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      expect(find.text('حجز موعد'), findsNWidgets(2));
    });

    testWidgets('selecting 2hr duration starting at 9:00 AM reports booked conflict', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final duration2HrFinder = find.text('2 hr');
      expect(duration2HrFinder, findsOneWidget);
      await tester.ensureVisible(duration2HrFinder);
      await tester.tap(duration2HrFinder);
      await tester.pumpAndSettle();

      final slot0Finder = find.text('9:00 AM');
      expect(slot0Finder, findsOneWidget);
      await tester.ensureVisible(slot0Finder);
      await tester.tap(slot0Finder);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('One or more required time slots are already booked.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping an already selected 30-min slot deselects it without triggering error feedback', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final slotFinder = find.widgetWithText(SlotCellWidget, '9:30 AM');
      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      await tester.tap(slotFinder);
      await tester.pumpAndSettle();

      expect(find.text('Booking Summary'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);

      await tester.tap(slotFinder);
      await tester.pumpAndSettle();

      expect(find.text('One or more required time slots are already booked.'), findsNothing);
      expect(find.text('One or more required time slots are unavailable.'), findsNothing);
      expect(find.text('No time slot selected yet.'), findsOneWidget);
    });

    testWidgets('ISSUE-018: pressing Reset clears active snackbar and resets state', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final bookedSlot = find.text('10:00 AM');
      await tester.ensureVisible(bookedSlot);
      await tester.tap(bookedSlot);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      final resetBtn = find.text('Reset');
      await tester.ensureVisible(resetBtn);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('selecting 11:00 AM dynamically updates 11:30 AM availability allowing consecutive 1hr booking', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      final slot1100 = find.widgetWithText(SlotCellWidget, '11:00 AM');
      final slot1130 = find.widgetWithText(SlotCellWidget, '11:30 AM');

      expect(slot1100, findsOneWidget);
      expect(slot1130, findsOneWidget);

      // Verify initial state: 11:30 AM is not valid start (dimmed/invalid)
      final initialCell1130 = tester.widget<SlotCellWidget>(slot1130);
      expect(initialCell1130.isValidStart, isFalse);

      // 1. Tap 11:00 AM
      await tester.ensureVisible(slot1100);
      await tester.tap(slot1100);
      await tester.pumpAndSettle();

      // Verify 11:30 AM is now valid start
      final updatedCell1130 = tester.widget<SlotCellWidget>(slot1130);
      expect(updatedCell1130.isValidStart, isTrue);

      // 2. Tap 11:30 AM
      await tester.ensureVisible(slot1130);
      await tester.tap(slot1130);
      await tester.pumpAndSettle();

      // Verify both are selected and duration is 1 hr
      final selected1100 = tester.widget<SlotCellWidget>(slot1100);
      final selected1130 = tester.widget<SlotCellWidget>(slot1130);
      expect(selected1100.isSelected, isTrue);
      expect(selected1130.isSelected, isTrue);

      expect(find.text('Booking Summary'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BookingSummaryWidget),
          matching: find.text('1 hr'),
        ),
        findsAtLeastNWidgets(1),
      );
    });
  });
}
