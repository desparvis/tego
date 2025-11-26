import 'package:flutter_test/flutter_test.dart';
import '../lib/core/utils/validators.dart';
import '../lib/domain/entities/sale.dart';
import '../lib/domain/entities/expense.dart';

void main() {
  group('Simple Unit Tests', () {
    // Validator Tests
    test('email validation works correctly', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('invalid'), 'Please enter a valid email');
      expect(Validators.validateEmail(''), 'Please enter your email');
    });

    test('password validation works correctly', () {
      expect(Validators.validatePassword('password123'), null);
      expect(Validators.validatePassword('123'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword(''), 'Please enter password');
    });

    test('amount validation works correctly', () {
      expect(Validators.validateAmount('100'), null);
      expect(Validators.validateAmount('abc'), 'Please enter valid amount');
    });

    // Entity Tests
    test('Sale entity creates correctly', () {
      final sale = Sale(
        id: '1',
        amount: 1000.0,
        date: '01-01-2024',
        timestamp: DateTime.now(),
      );
      
      expect(sale.id, '1');
      expect(sale.amount, 1000.0);
      expect(sale.date, '01-01-2024');
    });

    test('Sale toMap works correctly', () {
      final sale = Sale(
        amount: 1000.0,
        date: '01-01-2024',
        timestamp: DateTime.now(),
      );
      
      final map = sale.toMap();
      expect(map['amount'], 1000.0);
      expect(map['date'], '01-01-2024');
      expect(map.containsKey('timestamp'), true);
    });

    test('Expense entity creates correctly', () {
      final expense = Expense(
        id: '1',
        amount: 500.0,
        category: 'Rent',
        description: 'Monthly rent',
        date: '01-01-2024',
        timestamp: DateTime.now(),
      );
      
      expect(expense.id, '1');
      expect(expense.amount, 500.0);
      expect(expense.category, 'Rent');
      expect(expense.description, 'Monthly rent');
    });

    // Business Logic Tests
    test('sale amount calculation', () {
      final sales = [
        Sale(amount: 100, date: '01-01-2024'),
        Sale(amount: 200, date: '02-01-2024'),
        Sale(amount: 300, date: '03-01-2024'),
      ];
      
      final total = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      expect(total, 600.0);
    });

    test('expense categorization', () {
      final expenses = [
        Expense(amount: 100, category: 'Rent', description: 'Rent', date: '01-01-2024', timestamp: DateTime.now()),
        Expense(amount: 50, category: 'Utilities', description: 'Electric', date: '01-01-2024', timestamp: DateTime.now()),
        Expense(amount: 75, category: 'Rent', description: 'Rent 2', date: '01-01-2024', timestamp: DateTime.now()),
      ];
      
      final rentExpenses = expenses.where((e) => e.category == 'Rent').toList();
      expect(rentExpenses.length, 2);
      
      final totalRent = rentExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      expect(totalRent, 175.0);
    });

    test('date formatting validation', () {
      final dateRegex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
      
      expect(dateRegex.hasMatch('01-01-2024'), true);
      expect(dateRegex.hasMatch('1-1-2024'), false);
      expect(dateRegex.hasMatch('2024-01-01'), false);
    });
  });
}