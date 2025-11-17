import 'package:flutter_test/flutter_test.dart';
import 'package:tego/domain/entities/expense.dart';

void main() {
  group('Expense Entity Tests', () {
    test('should create expense with correct properties', () {
      // Arrange
      final expense = Expense(
        id: '1',
        amount: 1000.0,
        category: 'Food',
        description: 'Lunch',
        date: '01-01-2024',
        timestamp: DateTime(2024, 1, 1),
      );

      // Assert
      expect(expense.id, '1');
      expect(expense.amount, 1000.0);
      expect(expense.category, 'Food');
      expect(expense.description, 'Lunch');
      expect(expense.date, '01-01-2024');
    });

    test('should convert expense to map correctly', () {
      // Arrange
      final expense = Expense(
        amount: 500.0,
        category: 'Transport',
        description: 'Bus fare',
        date: '02-01-2024',
        timestamp: DateTime(2024, 1, 2),
      );

      // Act
      final map = expense.toMap();

      // Assert
      expect(map['amount'], 500.0);
      expect(map['category'], 'Transport');
      expect(map['description'], 'Bus fare');
      expect(map['date'], '02-01-2024');
    });

    test('should create expense from map correctly', () {
      // Arrange
      final map = {
        'amount': 750.0,
        'category': 'Utilities',
        'description': 'Electricity bill',
        'date': '03-01-2024',
        // timestamp will be null in test, should use DateTime.now() as fallback
      };

      // Act
      final expense = Expense.fromMap(map, 'test-id');

      // Assert
      expect(expense.id, 'test-id');
      expect(expense.amount, 750.0);
      expect(expense.category, 'Utilities');
      expect(expense.description, 'Electricity bill');
      expect(expense.date, '03-01-2024');
      expect(expense.timestamp, isA<DateTime>());
    });
  });
}