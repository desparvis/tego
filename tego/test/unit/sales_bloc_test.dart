import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/entities/sale.dart';

void main() {
  group('Sales Unit Tests', () {
    test('Sale entity creates with correct properties', () {
      final sale = Sale(
        id: 'test-id',
        amount: 1500.0,
        date: '15-01-2024',
        item: 'Test Item',
        timestamp: DateTime(2024, 1, 15),
      );

      expect(sale.id, 'test-id');
      expect(sale.amount, 1500.0);
      expect(sale.date, '15-01-2024');
      expect(sale.item, 'Test Item');
      expect(sale.timestamp?.year, 2024);
    });

    test('Sale toMap converts correctly', () {
      final sale = Sale(
        id: 'test-id',
        amount: 2000.0,
        date: '20-01-2024',
        item: 'Another Item',
        timestamp: DateTime(2024, 1, 20),
      );

      final map = sale.toMap();
      expect(map['amount'], 2000.0);
      expect(map['date'], '20-01-2024');
      expect(map['item'], 'Another Item');
      expect(map.containsKey('timestamp'), true);
    });

    test('Sale fromMap creates correct object', () {
      final map = {
        'amount': 750.0,
        'date': '10-01-2024',
        'item': 'Map Item',
      };

      final sale = Sale.fromMap(map, 'map-id');
      expect(sale.id, 'map-id');
      expect(sale.amount, 750.0);
      expect(sale.date, '10-01-2024');
      expect(sale.item, 'Map Item');
    });

    test('Multiple sales calculation', () {
      final sales = [
        Sale(amount: 100, date: '01-01-2024'),
        Sale(amount: 250, date: '02-01-2024'),
        Sale(amount: 150, date: '03-01-2024'),
      ];

      final total = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      expect(total, 500.0);

      final averageSale = total / sales.length;
      expect(averageSale, closeTo(166.67, 0.01));
    });

    test('Sales filtering by date range', () {
      final sales = [
        Sale(amount: 100, date: '01-01-2024'),
        Sale(amount: 200, date: '15-01-2024'),
        Sale(amount: 300, date: '31-01-2024'),
      ];

      // Filter sales from January 2024
      final januarySales = sales.where((sale) => sale.date.contains('01-2024')).toList();
      expect(januarySales.length, 3);

      // Filter sales from mid-month
      final midMonthSales = sales.where((sale) => sale.date.startsWith('15-')).toList();
      expect(midMonthSales.length, 1);
      expect(midMonthSales.first.amount, 200);
    });
  });
}