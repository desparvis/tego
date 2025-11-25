import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'offline_service.dart';

class SyncService {
  static Future<void> syncOfflineData() async {
    if (!await OfflineService.isOnline()) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Sync offline sales
      final offlineSales = await OfflineService.getOfflineSales();
      for (final sale in offlineSales) {
        sale.remove('offline_id');
        await FirestoreService.instance.addDocument('users/${user.uid}/sales', sale);
      }

      // Sync offline expenses
      final offlineExpenses = await OfflineService.getOfflineExpenses();
      for (final expense in offlineExpenses) {
        expense.remove('offline_id');
        await FirestoreService.instance.addDocument('users/${user.uid}/expenses', expense);
      }

      // Clear offline data after successful sync
      await OfflineService.clearOfflineData();
    } catch (e) {
      // Keep offline data if sync fails
    }
  }

  static Future<void> addSaleWithOfflineSupport(Map<String, dynamic> sale) async {
    if (await OfflineService.isOnline()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService.instance.addDocument('users/${user.uid}/sales', sale);
      }
    } else {
      await OfflineService.saveSaleOffline(sale);
    }
  }

  static Future<void> addExpenseWithOfflineSupport(Map<String, dynamic> expense) async {
    if (await OfflineService.isOnline()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService.instance.addDocument('users/${user.uid}/expenses', expense);
      }
    } else {
      await OfflineService.saveExpenseOffline(expense);
    }
  }
}