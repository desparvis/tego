import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static const String _salesKey = 'offline_sales';
  static const String _expensesKey = 'offline_expenses';
  static const String _inventoryKey = 'offline_inventory';
  static const String _debtsKey = 'offline_debts';
  static const String _remindersKey = 'offline_reminders';

  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Future<void> saveSaleOffline(Map<String, dynamic> sale) async {
    final prefs = await SharedPreferences.getInstance();
    final sales = await getOfflineSales();
    sale['offline_id'] = DateTime.now().millisecondsSinceEpoch.toString();
    sales.add(sale);
    await prefs.setString(_salesKey, jsonEncode(sales));
  }

  static Future<void> saveExpenseOffline(Map<String, dynamic> expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getOfflineExpenses();
    expense['offline_id'] = DateTime.now().millisecondsSinceEpoch.toString();
    expenses.add(expense);
    await prefs.setString(_expensesKey, jsonEncode(expenses));
  }

  static Future<List<Map<String, dynamic>>> getOfflineSales() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_salesKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<List<Map<String, dynamic>>> getOfflineExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_expensesKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_salesKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_inventoryKey);
    await prefs.remove(_debtsKey);
    await prefs.remove(_remindersKey);
  }

  static Future<bool> hasOfflineData() async {
    final sales = await getOfflineSales();
    final expenses = await getOfflineExpenses();
    return sales.isNotEmpty || expenses.isNotEmpty;
  }
}