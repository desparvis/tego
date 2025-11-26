import 'package:flutter_test/flutter_test.dart';
import '../lib/core/utils/validators.dart';
import '../lib/core/utils/date_formatter.dart';
import '../lib/domain/entities/sale.dart';
import '../lib/domain/entities/expense.dart';
import '../lib/domain/entities/inventory_item.dart';
import '../lib/domain/entities/user.dart';

void main() {
  group('Comprehensive Unit Tests', () {
    // Validators Tests
    group('Validators', () {
      test('validateEmail with various inputs', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.uk'), null);
        expect(Validators.validateEmail(''), 'Please enter your email');
        expect(Validators.validateEmail('invalid'), 'Please enter a valid email');
        expect(Validators.validateEmail('@domain.com'), 'Please enter a valid email');
        expect(Validators.validateEmail('test@'), 'Please enter a valid email');
      });

      test('validatePassword with various inputs', () {
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('123456'), null);
        expect(Validators.validatePassword(''), 'Please enter password');
        expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
        expect(Validators.validatePassword('abc'), 'Password must be at least 6 characters');
      });

      test('validateAmount with various inputs', () {
        expect(Validators.validateAmount('100'), null);
        expect(Validators.validateAmount('1000.50'), null);
        expect(Validators.validateAmount('0.01'), null);
        expect(Validators.validateAmount(''), 'Please enter amount');
        expect(Validators.validateAmount('abc'), 'Please enter valid amount');
      });
    });

    // Date Formatter Tests
    group('DateFormatter', () {
      test('formats dates correctly', () {
        final date = DateTime(2024, 1, 15);
        expect(DateFormatter.formatDate(date), '15-01-2024');
      });

      test('formats readable date', () {
        final date = DateTime(2024, 1, 15);
        expect(DateFormatter.formatDateReadable(date), 'Jan 15, 2024');
      });

      test('formats date with time', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final formatted = DateFormatter.formatDateTime(date);
        expect(formatted, contains('Jan 15, 2024 at'));
      });

      test('parses date strings', () {
        final date = DateFormatter.parseDate('15-01-2024');
        expect(date?.day, 15);
        expect(date?.month, 1);
        expect(date?.year, 2024);
      });

      test('gets relative time', () {
        final now = DateTime.now();
        final oneHourAgo = now.subtract(Duration(hours: 1));
        expect(DateFormatter.getRelativeTime(oneHourAgo), '1 hour ago');
      });

      test('checks if date is today', () {
        final now = DateTime.now();
        expect(DateFormatter.isToday(now), true);
        
        final yesterday = now.subtract(Duration(days: 1));
        expect(DateFormatter.isToday(yesterday), false);
      });

      test('gets current month', () {
        final month = DateFormatter.getCurrentMonth();
        expect(month, matches(r'^\w+ \d{4}$'));
      });
    });

    // Sale Entity Tests
    group('Sale Entity', () {
      test('creates sale with all properties', () {
        final sale = Sale(
          id: 'sale-1',
          amount: 1500.0,
          date: '15-01-2024',
          item: 'Product A',
          timestamp: DateTime(2024, 1, 15),
        );

        expect(sale.id, 'sale-1');
        expect(sale.amount, 1500.0);
        expect(sale.date, '15-01-2024');
        expect(sale.item, 'Product A');
        expect(sale.timestamp?.year, 2024);
      });

      test('creates sale with minimal properties', () {
        final sale = Sale(
          amount: 500.0,
          date: '10-01-2024',
        );

        expect(sale.amount, 500.0);
        expect(sale.date, '10-01-2024');
        expect(sale.item, '');
        expect(sale.id, null);
      });

      test('converts to map correctly', () {
        final sale = Sale(
          amount: 1000.0,
          date: '20-01-2024',
          item: 'Test Item',
          timestamp: DateTime(2024, 1, 20),
        );

        final map = sale.toMap();
        expect(map['amount'], 1000.0);
        expect(map['date'], '20-01-2024');
        expect(map['item'], 'Test Item');
        expect(map.containsKey('timestamp'), true);
      });

      test('creates from map correctly', () {
        final map = {
          'amount': 750.0,
          'date': '25-01-2024',
          'item': 'Map Item',
        };

        final sale = Sale.fromMap(map, 'map-id');
        expect(sale.id, 'map-id');
        expect(sale.amount, 750.0);
        expect(sale.date, '25-01-2024');
        expect(sale.item, 'Map Item');
      });
    });

    // Expense Entity Tests
    group('Expense Entity', () {
      test('creates expense with all properties', () {
        final expense = Expense(
          id: 'expense-1',
          amount: 200.0,
          category: 'Utilities',
          description: 'Electricity bill',
          date: '15-01-2024',
          timestamp: DateTime(2024, 1, 15),
        );

        expect(expense.id, 'expense-1');
        expect(expense.amount, 200.0);
        expect(expense.category, 'Utilities');
        expect(expense.description, 'Electricity bill');
        expect(expense.date, '15-01-2024');
      });

      test('converts to map correctly', () {
        final expense = Expense(
          amount: 150.0,
          category: 'Rent',
          description: 'Monthly rent',
          date: '01-01-2024',
          timestamp: DateTime(2024, 1, 1),
        );

        final map = expense.toMap();
        expect(map['amount'], 150.0);
        expect(map['category'], 'Rent');
        expect(map['description'], 'Monthly rent');
        expect(map['date'], '01-01-2024');
      });

      test('creates from map correctly', () {
        final map = {
          'amount': 300.0,
          'category': 'Supplies',
          'description': 'Office supplies',
          'date': '10-01-2024',
        };

        final expense = Expense.fromMap(map, 'expense-id');
        expect(expense.id, 'expense-id');
        expect(expense.amount, 300.0);
        expect(expense.category, 'Supplies');
        expect(expense.description, 'Office supplies');
        expect(expense.date, '10-01-2024');
      });
    });

    // Inventory Item Tests
    group('InventoryItem Entity', () {
      test('creates inventory item correctly', () {
        final item = InventoryItem(
          id: 'item-1',
          name: 'Product A',
          quantity: 10,
          stockCost: 50.0,
          intendedProfit: 25.0,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(item.id, 'item-1');
        expect(item.name, 'Product A');
        expect(item.quantity, 10);
        expect(item.stockCost, 50.0);
        expect(item.intendedProfit, 25.0);
        expect(item.sellingPrice, 75.0); // stockCost + intendedProfit
      });

      test('calculates values correctly', () {
        final item = InventoryItem(
          name: 'Product B',
          quantity: 5,
          stockCost: 100.0,
          intendedProfit: 50.0,
          createdAt: DateTime.now(),
        );

        expect(item.sellingPrice, 150.0); // 100 + 50
        expect(item.totalStockValue, 500.0); // 5 * 100
        expect(item.totalIntendedProfit, 250.0); // 5 * 50
      });

      test('converts to map correctly', () {
        final createdAt = DateTime(2024, 1, 15);
        final item = InventoryItem(
          name: 'Product C',
          quantity: 3,
          stockCost: 25.0,
          intendedProfit: 15.0,
          createdAt: createdAt,
        );

        final map = item.toMap();
        expect(map['name'], 'Product C');
        expect(map['quantity'], 3);
        expect(map['stockCost'], 25.0);
        expect(map['intendedProfit'], 15.0);
        expect(map['createdAt'], createdAt);
      });

      test('creates from map correctly', () {
        final map = {
          'name': 'Product D',
          'stockCost': 30.0,
          'intendedProfit': 20.0,
          'quantity': 8,
        };

        final item = InventoryItem.fromMap(map, 'item-id');
        expect(item.id, 'item-id');
        expect(item.name, 'Product D');
        expect(item.stockCost, 30.0);
        expect(item.intendedProfit, 20.0);
        expect(item.quantity, 8);
        expect(item.sellingPrice, 50.0);
      });
    });

    // User Entity Tests
    group('User Entity', () {
      test('creates user correctly', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          totalSalesCount: 5,
          totalAmount: 1000.0,
        );

        expect(user.id, 'user-1');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.totalSalesCount, 5);
        expect(user.totalAmount, 1000.0);
      });

      test('converts to map correctly', () {
        final user = User(
          id: 'user-2',
          email: 'user@test.com',
          displayName: 'John Doe',
          totalSalesCount: 10,
          totalAmount: 2500.0,
        );

        final map = user.toMap();
        expect(map['email'], 'user@test.com');
        expect(map['displayName'], 'John Doe');
        expect(map['totalSalesCount'], 10);
        expect(map['totalAmount'], 2500.0);
      });

      test('creates from map correctly', () {
        final map = {
          'email': 'jane@example.com',
          'displayName': 'Jane Smith',
          'totalSalesCount': 3,
          'totalAmount': 750.0,
        };

        final user = User.fromMap(map, 'user-3');
        expect(user.id, 'user-3');
        expect(user.email, 'jane@example.com');
        expect(user.displayName, 'Jane Smith');
        expect(user.totalSalesCount, 3);
        expect(user.totalAmount, 750.0);
      });

      test('copyWith creates updated user', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          totalSalesCount: 5,
        );

        final updatedUser = user.copyWith(
          displayName: 'Updated User',
          totalSalesCount: 10,
        );

        expect(updatedUser.id, 'user-1');
        expect(updatedUser.email, 'test@example.com');
        expect(updatedUser.displayName, 'Updated User');
        expect(updatedUser.totalSalesCount, 10);
      });
    });

    // Business Logic Tests
    group('Business Logic', () {
      test('calculates total sales correctly', () {
        final sales = [
          Sale(amount: 100.0, date: '01-01-2024'),
          Sale(amount: 250.0, date: '02-01-2024'),
          Sale(amount: 150.0, date: '03-01-2024'),
        ];

        final total = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
        expect(total, 500.0);
      });

      test('calculates total expenses correctly', () {
        final expenses = [
          Expense(amount: 50.0, category: 'Rent', description: 'Rent', date: '01-01-2024', timestamp: DateTime.now()),
          Expense(amount: 30.0, category: 'Utilities', description: 'Electric', date: '01-01-2024', timestamp: DateTime.now()),
          Expense(amount: 20.0, category: 'Supplies', description: 'Office', date: '01-01-2024', timestamp: DateTime.now()),
        ];

        final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
        expect(total, 100.0);
      });

      test('calculates profit correctly', () {
        final totalSales = 1000.0;
        final totalExpenses = 300.0;
        final profit = totalSales - totalExpenses;
        expect(profit, 700.0);
      });

      test('filters sales by date range', () {
        final sales = [
          Sale(amount: 100.0, date: '01-01-2024'),
          Sale(amount: 200.0, date: '15-01-2024'),
          Sale(amount: 300.0, date: '31-01-2024'),
          Sale(amount: 400.0, date: '01-02-2024'),
        ];

        final januarySales = sales.where((sale) => sale.date.contains('01-2024')).toList();
        expect(januarySales.length, 3);

        final februarySales = sales.where((sale) => sale.date.contains('02-2024')).toList();
        expect(februarySales.length, 1);
      });

      test('groups expenses by category', () {
        final expenses = [
          Expense(amount: 100.0, category: 'Rent', description: 'Rent 1', date: '01-01-2024', timestamp: DateTime.now()),
          Expense(amount: 50.0, category: 'Utilities', description: 'Electric', date: '01-01-2024', timestamp: DateTime.now()),
          Expense(amount: 75.0, category: 'Rent', description: 'Rent 2', date: '01-01-2024', timestamp: DateTime.now()),
          Expense(amount: 25.0, category: 'Utilities', description: 'Water', date: '01-01-2024', timestamp: DateTime.now()),
        ];

        final rentExpenses = expenses.where((e) => e.category == 'Rent').toList();
        final utilityExpenses = expenses.where((e) => e.category == 'Utilities').toList();

        expect(rentExpenses.length, 2);
        expect(utilityExpenses.length, 2);

        final totalRent = rentExpenses.fold<double>(0, (sum, e) => sum + e.amount);
        final totalUtilities = utilityExpenses.fold<double>(0, (sum, e) => sum + e.amount);

        expect(totalRent, 175.0);
        expect(totalUtilities, 75.0);
      });
    });
  });
}