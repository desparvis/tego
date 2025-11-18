import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../core/services/firestore_service.dart';

/// Concrete implementation of SalesRepository using Firestore
/// Handles data persistence and retrieval
class SalesRepositoryImpl implements SalesRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  const SalesRepositoryImpl(this._firestoreService, this._auth);

  @override
  Future<void> addSale(Sale sale) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final data = sale.toMap();
    data['timestamp'] = FieldValue.serverTimestamp(); // Server timestamp for consistency
    
    await _firestoreService.addDocument('users/${user.uid}/sales', data);
  }

  @override
  Future<List<Sale>> getSales() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users/${user.uid}/sales')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Sale.fromMap(doc.data(), doc.id))
        .toList();
  }
}