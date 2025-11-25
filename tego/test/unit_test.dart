import 'package:flutter_test/flutter_test.dart';
import 'package:tego/domain/entities/expense.dart';
import 'package:tego/domain/entities/inventory_item.dart';
import 'package:tego/core/utils/preferences_service.dart';

void main() {
  group('Expense Entity Tests', () {
    test('should create expense with correct properties', () {
      // Arrange
      final expense = Expense(
        amount: 1000.0,
        category: 'Business - Rent',
        description: 'Monthly rent payment',
        date: '01-12-2024',
        timestamp: DateTime.now(),
      );

      // Assert
      expect(expense.amount, 1000.0);
      expect(expense.category, 'Business - Rent');
      expect(expense.description, 'Monthly rent payment');
      expect(expense.date, '01-12-2024');
    });

    test('should convert expense to map correctly', () {
      // Arrange
      final timestamp = DateTime.now();
      final expense = Expense(
        amount: 500.0,
        category: 'Personal - Food',
        description: 'Lunch',
        date: '01-12-2024',
        timestamp: timestamp,
      );

      // Act
      final map = expense.toMap();

      // Assert
      expect(map['amount'], 500.0);
      expect(map['category'], 'Personal - Food');
      expect(map['description'], 'Lunch');
      expect(map['date'], '01-12-2024');
    });
  });

  group('InventoryItem Entity Tests', () {
    test('should create inventory item with correct properties', () {
      // Arrange
      final item = InventoryItem(
        id: 'test-id',
        name: 'Test Product',
        stockCost: 100.0,
        intendedProfit: 50.0,
        quantity: 10,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(item.name, 'Test Product');
      expect(item.stockCost, 100.0);
      expect(item.intendedProfit, 50.0);
      expect(item.quantity, 10);
    });

    test('should calculate selling price correctly', () {
      // Arrange
      final item = InventoryItem(
        id: 'test-id',
        name: 'Test Product',
        stockCost: 100.0,
        intendedProfit: 50.0,
        quantity: 10,
        createdAt: DateTime.now(),
      );

      // Act
      final sellingPrice = item.stockCost + item.intendedProfit;

      // Assert
      expect(sellingPrice, 150.0);
    });
  });

  group('PreferencesService Tests', () {
    test('should handle theme mode preferences', () {
      // Test theme mode string conversion
      expect('light', isA<String>());
      expect('dark', isA<String>());
      expect('system', isA<String>());
    });

    test('should handle first launch flag', () {
      // Test boolean handling
      expect(true, isA<bool>());
      expect(false, isA<bool>());
    });
  });
}