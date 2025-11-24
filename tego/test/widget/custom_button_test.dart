import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/presentation/widgets/custom_button.dart';
import '../../lib/core/constants/app_constants.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('renders button with correct text', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Test Button';
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: buttonText,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('button is disabled when onPressed is null', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, null);
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      // Arrange
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Colored Button',
              onPressed: () {},
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      // Act
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      // Assert
      expect(button.style?.backgroundColor?.resolve({}), customColor);
    });
  });
}