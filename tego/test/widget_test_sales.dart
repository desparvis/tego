import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tego/presentation/pages/sales_recording_screen.dart';

void main() {
  group('Sales Recording Screen Widget Tests', () {
    testWidgets('should display sales recording form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SalesRecordingScreen(),
        ),
      );

      expect(find.text('Sales Recording'), findsWidgets);
      expect(find.text('Sale Amount'), findsOneWidget);
      expect(find.text('Sale Date'), findsOneWidget);
      expect(find.text('Add Sale'), findsOneWidget);
    });

    testWidgets('should show validation error for empty amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SalesRecordingScreen(),
        ),
      );

      await tester.tap(find.text('Add Sale'));
      await tester.pump();

      expect(find.text('Please enter sale amount'), findsOneWidget);
    });
  });
}