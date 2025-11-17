import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tego/presentation/bloc/expense_bloc.dart';
import 'package:tego/presentation/pages/expense_recording_screen.dart';

void main() {
  group('Expense Recording Screen Widget Tests', () {
    testWidgets('should display expense recording form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(),
            child: const ExpenseRecordingScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Expense Recording'), findsWidgets);
      expect(find.text('Expense Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Expense Date'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
    });

    testWidgets('should show validation error for empty amount', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(),
            child: const ExpenseRecordingScreen(),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Add Expense'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter expense amount'), findsOneWidget);
    });

    testWidgets('should show validation error for empty description', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(),
            child: const ExpenseRecordingScreen(),
          ),
        ),
      );

      // Act - Fill amount but leave description empty
      await tester.enterText(find.byType(TextFormField).first, '1000');
      await tester.tap(find.text('Add Expense'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter description'), findsOneWidget);
    });
  });
}