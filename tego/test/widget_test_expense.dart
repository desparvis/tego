import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tego/presentation/widgets/custom_button.dart';
import 'package:tego/presentation/widgets/custom_text_field.dart';

void main() {
  group('Custom Widget Tests', () {
    testWidgets('CustomButton should display text and handle tap', (WidgetTester tester) async {
      bool tapped = false;
      
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('CustomTextField should display placeholder', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholder: 'Enter text',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('CustomTextField should handle password mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholder: 'Password',
              controller: TextEditingController(),
              isPassword: true,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('CustomButton should show loading state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });
  });
}