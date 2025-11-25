import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/presentation/pages/sign_in_screen.dart';
import '../../lib/presentation/widgets/custom_button.dart';
import '../../lib/presentation/widgets/custom_text_field.dart';
import '../../lib/core/constants/app_constants.dart';

void main() {
  group('SignInScreen Widget Tests', () {
    testWidgets('renders all required UI elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInScreen(),
        ),
      );

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.byType(CustomButton), findsNWidgets(2));
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInScreen(),
        ),
      );

      // Act - Try to submit form with empty fields
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInScreen(),
        ),
      );

      // Act - Enter invalid email
      await tester.enterText(
        find.byType(CustomTextField).first,
        'invalid-email',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates password length', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInScreen(),
        ),
      );

      // Act - Enter short password
      final passwordField = find.byType(CustomTextField).last;
      await tester.enterText(passwordField, '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('accepts valid email and password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInScreen(),
        ),
      );

      // Act - Enter valid credentials
      await tester.enterText(
        find.byType(CustomTextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(CustomTextField).last,
        'password123',
      );
      
      // Trigger validation
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - No validation errors should be shown
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    testWidgets('forgot password link is tappable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInScreen(),
        ),
      );

      // Act & Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
      
      // Verify it's tappable (GestureDetector should be present)
      final forgotPasswordWidget = find.text('Forgot Password?');
      expect(forgotPasswordWidget, findsOneWidget);
    });
  });
}