import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/core/extensions/snack_bar_extensions.dart';
import 'package:booking_appointments/core/functions/show_snack_bar.dart';

void main() {
  group('showSnackBar Unit & Widget Tests', () {
    testWidgets('showSnackBar clears previous SnackBar before showing new one', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => showSnackBar(
                        context: context,
                        message: 'First Message',
                      ),
                      child: const Text('Show First'),
                    ),
                    ElevatedButton(
                      onPressed: () => showSnackBar(
                        context: context,
                        message: 'Second Message',
                      ),
                      child: const Text('Show Second'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Tap first button
      await tester.tap(find.text('Show First'));
      await tester.pump();

      expect(find.text('First Message'), findsOneWidget);

      // Rapidly tap second button before first finishes
      await tester.tap(find.text('Show Second'));
      await tester.pump();

      // First message should immediately be cleared, replaced by Second Message
      expect(find.text('First Message'), findsNothing);
      expect(find.text('Second Message'), findsOneWidget);
    });

    testWidgets(
      'SnackBarContextExtension functions trigger showSnackBar correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.showSuccessSnackBar('Success Message');
                    },
                    child: const Text('Show Success'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Success'));
        await tester.pump();

        expect(find.text('Success Message'), findsOneWidget);
      },
    );
  });
}
