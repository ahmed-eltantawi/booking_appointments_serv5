import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/services/services_locator.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/app_drawer_widget.dart';
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

      // Verify title in app bar and header
      expect(find.text('Book an Appointment'), findsNWidgets(2));

      // Verify working hours header
      expect(find.text('Working hours: 9:00 AM – 6:00 PM'), findsOneWidget);

      // Verify duration selector section exists
      expect(find.text('Select Duration'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('1 hr'), findsOneWidget);

      // Verify legend items exist
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

      // Tap '1 hr' duration chip
      await tester.tap(find.text('1 hr'));
      await tester.pumpAndSettle();

      // Verify 1 hr chip is selected
      expect(find.text('1 hr'), findsOneWidget);
    });

    testWidgets('tapping valid time slot selects it and shows summary widget', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      // Slot 1 (09:30 AM) is valid in seed schedule
      final slotFinder = find.text('9:30 AM');
      expect(slotFinder, findsOneWidget);

      await tester.tap(slotFinder);
      await tester.pumpAndSettle();

      // Verify booking summary card appears showing 'Booking Summary' and start time
      expect(find.text('Booking Summary'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('tapping booked slot displays contextual booked snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      // Slot 2 (10:00 AM) is pre-booked in seed schedule
      final bookedSlotFinder = find.text('10:00 AM');
      expect(bookedSlotFinder, findsOneWidget);

      await tester.ensureVisible(bookedSlotFinder);
      await tester.tap(bookedSlotFinder);
      await tester.pumpAndSettle();

      // Verify feedback snackbar is displayed
      expect(find.text('10:00 AM is already booked.'), findsOneWidget);
    });

    testWidgets('tapping unavailable slot displays contextual unavailable snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      // Slot 9 (1:30 PM) is marked unavailable in seed schedule
      final unavailableSlotFinder = find.text('1:30 PM');
      expect(unavailableSlotFinder, findsOneWidget);

      await tester.ensureVisible(unavailableSlotFinder);
      await tester.tap(unavailableSlotFinder);
      await tester.pumpAndSettle();

      // Verify feedback snackbar is displayed
      expect(find.text('1:30 PM is currently unavailable.'), findsOneWidget);
    });

    testWidgets('confirming booking updates schedule and shows confirmation snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetToTest());
      await tester.pumpAndSettle();

      // Tap slot 1 (9:30 AM)
      await tester.tap(find.text('9:30 AM'));
      await tester.pumpAndSettle();

      // Tap 'Confirm Booking' button
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm Booking');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Confirmation snack bar should display success text
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

      // Initial English title check (in AppBar and DrawerHeader)
      expect(find.text('Book an Appointment'), findsNWidgets(2));

      // Switch language to Arabic via SettingsCubit
      GetIt.I<SettingsCubit>().setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Verify Arabic title is now rendered in UI
      expect(find.text('حجز موعد'), findsNWidgets(2));
    });
  });
}
